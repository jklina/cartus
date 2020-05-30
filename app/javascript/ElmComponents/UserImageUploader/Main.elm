module ElmComponents.UserImageUploader.Main exposing (main)

import Base64
import Browser
import Bytes exposing (Bytes)
import ElmComponents.MD5.Main as MD5
import File exposing (File)
import File.Select as Select
import Hex.Convert
import Html exposing (Html, a, div, img, text)
import Html.Attributes exposing (class, src)
import Html.Events exposing (onClick)
import Http exposing (Header)
import Json.Decode exposing (Decoder, field, int, keyValuePairs, map, map3, string)
import Json.Encode as Encode
import Task exposing (Task)



-- MODEL


type alias Model =
    { file : Maybe FileWithInfo
    , existingImageUrl : Maybe String
    }


type alias FileIdentifyingInfo =
    { signedId : String
    , url : String
    , headers : List Header
    }


type alias FileWithInfo =
    { file : File
    , checksum : Maybe String
    , signedId : Maybe String
    , uploadUrl : Maybe String
    , previewUrl : Maybe String
    , headers : Maybe (List Header)
    , status : Status
    , railsId : Maybe Int
    }


type Status
    = Waiting
    | Uploading Float
    | UploadComplete
    | RailsImageCreated
    | FailUpload
    | FailDelete



-- MESSAGE


type Msg
    = GotUploadUrl (Result Http.Error FileIdentifyingInfo)
    | GotFile File
    | SelectFile
    | ImageCreated (Result Http.Error Int)
    | UploadFinished (Result Http.Error ())
    | GotProgress Http.Progress
    | GotPreview String
    | GotChecksum String
    | DeleteFile
    | ImageDeleted (Result Http.Error ())



-- INIT


init : Maybe String -> ( Model, Cmd Msg )
init existingProfileImageUrl =
    case existingProfileImageUrl of
        Just url ->
            ( Model Nothing (Just url), Cmd.none )

        Nothing ->
            ( Model Nothing Nothing, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    case model.file of
        Nothing ->
            case model.existingImageUrl of
                Nothing ->
                    div [ onClick SelectFile, class "h-16 bg-gray-200 border-gray-500 border-dotted border text-center flex items-center justify-center" ] [ text "Upload Photos" ]

                Just url ->
                    div [] [ img [ src url ] [] ]

        Just file ->
            case file.status of
                Waiting ->
                    div [ onClick SelectFile, class "h-16 bg-gray-200 border-gray-500 border-dotted border text-center " ] [ text "Upload Photos" ]

                _ ->
                    renderPreview file


renderPreview : FileWithInfo -> Html Msg
renderPreview file =
    div [ class "bg-gray-200 border-gray-500 border-dotted border flex flex-wrap" ] [ previewImage file ]


previewImage : FileWithInfo -> Html Msg
previewImage file =
    case ( file.previewUrl, file.status ) of
        ( Just url, Uploading percentComplete ) ->
            div [] [ img [ src url ] [], text (String.fromFloat percentComplete) ]

        ( Just url, Waiting ) ->
            div [] [ img [ src url ] [], text "Waiting" ]

        ( Just url, _ ) ->
            div [] [ img [ src url ] [], text "Complete", a [ class "text-sm text-red-800", onClick DeleteFile ] [ text "Delete" ] ]

        ( Nothing, Waiting ) ->
            div [] [ text "Loading" ]

        ( Nothing, _ ) ->
            text "Nothing"



-- UPDATE
-- We start by selecting files. This kicks off tasks to fetch their preview
-- urls and their checksums. At this time, the files are also added to the model.
-- With the checksums, we then update the files in the model with the versions
-- with checksums and kick off a task to fetch the urls that we'll upload
-- the files to.


updateFileWithInfoWithUrlUploadInfo : FileWithInfo -> FileIdentifyingInfo -> FileWithInfo
updateFileWithInfoWithUrlUploadInfo fileWithInfo urlUploadInfo =
    { fileWithInfo
        | headers = Just urlUploadInfo.headers
        , uploadUrl = Just urlUploadInfo.url
        , signedId = Just urlUploadInfo.signedId
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotUploadUrl result ->
            case result of
                Ok uploadUrlInfo ->
                    let
                        originalFileWithInfoResult =
                            model.file
                    in
                    case originalFileWithInfoResult of
                        Nothing ->
                            ( model, Cmd.none )

                        Just originalFileWithInfo ->
                            let
                                updatedFileWithInfo =
                                    updateFileWithInfoWithUrlUploadInfo originalFileWithInfo uploadUrlInfo
                            in
                            ( { model | file = Just updatedFileWithInfo }, uploadFile updatedFileWithInfo )

                Err _ ->
                    ( model, Cmd.none )

        GotFile selectedFile ->
            let
                selectedFileWithInfo =
                    initializeNewFileWithInfoFromFile selectedFile

                filePreviewUrlRequest =
                    File.toUrl selectedFile

                checksumRequest =
                    buildChecksumFromFile selectedFileWithInfo
            in
            ( { model | file = Just selectedFileWithInfo }
            , Cmd.batch [ Task.perform GotChecksum checksumRequest, Task.perform GotPreview filePreviewUrlRequest ]
            )

        GotPreview url ->
            let
                oldFile =
                    model.file
            in
            case oldFile of
                Nothing ->
                    ( model, Cmd.none )

                Just originalFile ->
                    ( { model | file = Just { originalFile | previewUrl = Just url } }, Cmd.none )

        GotChecksum checksum ->
            let
                oldFile =
                    model.file
            in
            case oldFile of
                Nothing ->
                    ( model, Cmd.none )

                Just originalFile ->
                    let
                        newFile =
                            { originalFile | checksum = Just checksum }
                    in
                    ( { model | file = Just newFile }, requestUrl newFile )

        GotProgress progress ->
            case progress of
                Http.Sending p ->
                    let
                        oldFile =
                            model.file
                    in
                    case oldFile of
                        Nothing ->
                            ( model, Cmd.none )

                        Just originalFile ->
                            let
                                newStatus =
                                    Uploading (Http.fractionSent p)

                                newFileWithUploadInfo =
                                    { originalFile | status = newStatus }
                            in
                            ( { model | file = Just newFileWithUploadInfo }, Cmd.none )

                Http.Receiving _ ->
                    ( model, Cmd.none )

        SelectFile ->
            ( model, Select.file [ "image/*" ] GotFile )

        UploadFinished result ->
            case result of
                Ok _ ->
                    let
                        oldFile =
                            model.file
                    in
                    case oldFile of
                        Nothing ->
                            ( model, Cmd.none )

                        Just originalFile ->
                            let
                                updatedFile =
                                    { originalFile | status = UploadComplete }
                            in
                            ( { model | file = Just updatedFile }, buildRailsImage updatedFile )

                Err _ ->
                    ( updateFileStatus FailUpload model, Cmd.none )

        ImageCreated result ->
            case result of
                Ok id ->
                    let
                        oldFile =
                            model.file
                    in
                    case oldFile of
                        Nothing ->
                            ( model, Cmd.none )

                        Just originalFile ->
                            let
                                updatedFile =
                                    { originalFile | status = RailsImageCreated, railsId = Just id }
                            in
                            ( { model | file = Just updatedFile }, Cmd.none )

                Err _ ->
                    ( updateFileStatus FailUpload model, Cmd.none )

        DeleteFile ->
            let
                oldFile =
                    model.file
            in
            case oldFile of
                Just originalFile ->
                    if originalFile.status == RailsImageCreated then
                        ( model, deleteImage originalFile )

                    else
                        ( { model | file = Nothing }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        ImageDeleted result ->
            case result of
                Ok _ ->
                    ( { model | file = Nothing }, Cmd.none )

                Err _ ->
                    ( updateFileStatus FailDelete model, Cmd.none )


initializeNewFileWithInfoFromFile : File -> FileWithInfo
initializeNewFileWithInfoFromFile file =
    FileWithInfo file Nothing Nothing Nothing Nothing Nothing Waiting Nothing


updateFileStatus : Status -> Model -> Model
updateFileStatus newStatus originalModel =
    let
        oldFile =
            originalModel.file
    in
    case oldFile of
        Nothing ->
            originalModel

        Just originalFile ->
            let
                updatedFile =
                    { originalFile | status = newStatus }
            in
            { originalModel | file = Just updatedFile }


buildChecksumFromFile : FileWithInfo -> Task x String
buildChecksumFromFile fileWithInfo =
    Task.map buildChecksum (File.toBytes fileWithInfo.file)


buildChecksum : Bytes -> String
buildChecksum fileBytes =
    let
        hexBytes =
            MD5.fromBytes fileBytes
                |> Hex.Convert.toBytes
    in
    case hexBytes of
        Just bytes ->
            Base64.fromBytes bytes |> Maybe.withDefault ""

        Nothing ->
            ""


requestUrl : FileWithInfo -> Cmd Msg
requestUrl file =
    Http.post
        { url = "/rails/active_storage/direct_uploads"
        , body = Http.jsonBody (urlRequest file)
        , expect = Http.expectJson GotUploadUrl urlDecoder
        }


buildRailsImage : FileWithInfo -> Cmd Msg
buildRailsImage fileInfo =
    Http.post
        { url = "/user_profile_images"
        , body = Http.jsonBody (imageParams fileInfo)
        , expect = Http.expectJson ImageCreated imageDecoder
        }


uploadFile : FileWithInfo -> Cmd Msg
uploadFile fileWithInfo =
    Http.request
        { method = "PUT"
        , url = Maybe.withDefault "" fileWithInfo.uploadUrl
        , headers = Maybe.withDefault [] fileWithInfo.headers
        , body = Http.fileBody fileWithInfo.file
        , expect = Http.expectWhatever UploadFinished
        , timeout = Nothing
        , tracker = Just (File.name fileWithInfo.file)
        }


deleteImage : FileWithInfo -> Cmd Msg
deleteImage fileWithInfo =
    case fileWithInfo.railsId of
        Just id ->
            Http.request
                { method = "DELETE"
                , url = "/user_profile_images/" ++ String.fromInt id
                , expect = Http.expectWhatever ImageDeleted
                , timeout = Nothing
                , headers = []
                , body = Http.emptyBody
                , tracker = Nothing
                }

        Nothing ->
            Cmd.none


urlDecoder : Decoder FileIdentifyingInfo
urlDecoder =
    map3 FileIdentifyingInfo
        (field "signed_id" string)
        (field "direct_upload" (field "url" string))
        (field "direct_upload" (field "headers" (keyValuePairs string))
            |> map (List.map (\( a, b ) -> Http.header a b))
        )


imageDecoder : Decoder Int
imageDecoder =
    field "id" int


urlRequest : FileWithInfo -> Encode.Value
urlRequest fileWithInfo =
    Encode.object
        [ ( "blob"
          , Encode.object
                [ ( "filename", Encode.string (File.name fileWithInfo.file) )
                , ( "content_type", Encode.string (File.mime fileWithInfo.file) )
                , ( "byte_size", Encode.string (String.fromInt (File.size fileWithInfo.file)) )
                , ( "checksum", Encode.string (Maybe.withDefault "" fileWithInfo.checksum) )
                ]
          )
        ]


imageParams : FileWithInfo -> Encode.Value
imageParams fileWithInfo =
    let
        signedId =
            Maybe.withDefault "" fileWithInfo.signedId
    in
    Encode.object
        [ ( "image", Encode.object [ ( "image", Encode.string signedId ) ] ) ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.file of
        Nothing ->
            Sub.none

        Just fileWithInfo ->
            case fileWithInfo.status of
                Uploading _ ->
                    Http.track (File.name fileWithInfo.file) GotProgress

                _ ->
                    Sub.none



-- MAIN


main : Program (Maybe String) Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
