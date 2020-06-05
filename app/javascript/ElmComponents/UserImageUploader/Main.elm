module ElmComponents.UserImageUploader.Main exposing (main)

import Base64
import Browser
import Bytes exposing (Bytes)
import ElmComponents.MD5.Main as MD5
import File exposing (File)
import File.Select as Select
import Hex.Convert
import Html exposing (Html, a, div, img, text)
import Html.Attributes exposing (class, src, style)
import Html.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Http exposing (Header)
import Json.Decode exposing (Decoder, decodeValue, field, int, keyValuePairs, map, map2, map3, string)
import Json.Encode as Encode
import Task exposing (Task)



-- MODEL


type alias Model =
    { file : Maybe File
    , checksum : Maybe String
    , signedId : Maybe String
    , uploadUrl : Maybe String
    , previewUrl : Maybe String
    , headers : Maybe (List Header)
    , status : Status
    , existingImageUrl : Maybe String
    , displayMenu : Bool
    , railsId : Maybe Int
    }


type alias FileIdentifyingInfo =
    { signedId : String
    , url : String
    , headers : List Header
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
    | DisplayMenu
    | HideMenu
    | ImageDeleted (Result Http.Error ())



-- INIT


init : Encode.Value -> ( Model, Cmd Msg )
init flags =
    ( case decodeValue flagsDecoder flags of
        Ok model ->
            model

        Err _ ->
            { file = Nothing
            , checksum = Nothing
            , signedId = Nothing
            , uploadUrl = Nothing
            , previewUrl = Nothing
            , headers = Nothing
            , status = Waiting
            , existingImageUrl = Nothing
            , displayMenu = False
            , railsId = Nothing
            }
    , Cmd.none
    )



-- VIEW


view : Model -> Html Msg
view model =
    case model.file of
        Nothing ->
            case model.existingImageUrl of
                Nothing ->
                    div [ onClick SelectFile, class "h-16 bg-gray-200 border-gray-500 border-dotted border text-center flex items-center justify-center" ] [ text "Upload Photos" ]

                Just url ->
                    if model.displayMenu then
                        renderMenu url

                    else
                        renderImage url

        Just _ ->
            case model.status of
                Waiting ->
                    div [ onClick SelectFile, class "h-16 bg-gray-200 border-gray-500 border-dotted border text-center " ] [ text "Upload Photos" ]

                RailsImageCreated ->
                    case model.previewUrl of
                        Just url ->
                            if model.displayMenu then
                                renderMenu url

                            else
                                renderImage url

                        Nothing ->
                            div [ onClick SelectFile, class "h-16 bg-gray-200 border-gray-500 border-dotted border text-center flex items-center justify-center" ] [ text "Upload Photos" ]

                _ ->
                    renderPreview model


renderImage : String -> Html Msg
renderImage url =
    div [] [ img [ src url, onMouseEnter DisplayMenu, class "border-dotted border-gray-600 border rounded-t" ] [] ]


renderMenu : String -> Html Msg
renderMenu url =
    div [ onMouseLeave HideMenu, style "cursor" "pointer" ]
        [ img [ src url, class "border-dotted border-gray-600 border rounded-t" ] []
        , div [ class "bg-gray-300 -mt-12 relative h-12 border-dotted border-gray-600 border text-sm text-center" ] [ a [ onClick SelectFile, class "text-sm" ] [ text "Upload new image?" ], a [ class "text-sm text-red-800", onClick DeleteFile ] [ text "Delete" ] ]
        ]


renderPreview : Model -> Html Msg
renderPreview file =
    div [ class "bg-gray-200 border-gray-500 border-dotted border flex flex-wrap" ] [ previewImage file ]


previewImage : Model -> Html Msg
previewImage file =
    case ( file.previewUrl, file.status ) of
        ( Just url, Uploading percentComplete ) ->
            div [] [ img [ src url, class "rounded-t" ] [], text (String.fromFloat percentComplete) ]

        ( Just url, Waiting ) ->
            div [] [ img [ src url, class "rounded-t" ] [], text "Waiting" ]

        ( Just url, _ ) ->
            div [] [ img [ src url, class "rounded-t" ] [], text "Complete" ]

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


updateModelWithUrlUploadInfo : Model -> FileIdentifyingInfo -> Model
updateModelWithUrlUploadInfo model urlUploadInfo =
    { model
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
                        updatedModel =
                            updateModelWithUrlUploadInfo model uploadUrlInfo
                    in
                    ( updatedModel, uploadFile updatedModel )

                Err _ ->
                    ( model, Cmd.none )

        GotFile selectedFile ->
            let
                filePreviewUrlRequest =
                    File.toUrl selectedFile

                checksumRequest =
                    buildChecksumFromFile selectedFile
            in
            ( { model | file = Just selectedFile }
            , Cmd.batch [ Task.perform GotChecksum checksumRequest, Task.perform GotPreview filePreviewUrlRequest ]
            )

        GotPreview url ->
            ( { model | previewUrl = Just url }, Cmd.none )

        GotChecksum checksum ->
            let
                newModel =
                    { model | checksum = Just checksum }
            in
            ( newModel, requestUrl newModel )

        GotProgress progress ->
            case progress of
                Http.Sending p ->
                    let
                        newStatus =
                            Uploading (Http.fractionSent p)
                    in
                    ( { model | status = newStatus }, Cmd.none )

                Http.Receiving _ ->
                    ( model, Cmd.none )

        SelectFile ->
            ( model, Select.file [ "image/*" ] GotFile )

        UploadFinished result ->
            case result of
                Ok _ ->
                    let
                        newModel =
                            { model | status = UploadComplete }
                    in
                    ( newModel, buildRailsImage newModel )

                Err _ ->
                    ( { model | status = FailUpload }, Cmd.none )

        ImageCreated result ->
            case result of
                Ok id ->
                    ( { model | status = RailsImageCreated, railsId = Just id }, Cmd.none )

                Err _ ->
                    ( { model | status = FailUpload }, Cmd.none )

        DeleteFile ->
            case ( model.file, model.railsId ) of
                ( Just file, Just id ) ->
                    ( model, deleteImage model )

                ( _, _ ) ->
                    let
                        newModel =
                            { file = Nothing
                            , checksum = Nothing
                            , signedId = Nothing
                            , uploadUrl = Nothing
                            , previewUrl = Nothing
                            , headers = Nothing
                            , status = Waiting
                            , existingImageUrl = Nothing
                            , displayMenu = False
                            , railsId = Nothing
                            }
                    in
                    ( newModel, Cmd.none )

        ImageDeleted result ->
            case result of
                Ok _ ->
                    let
                        newModel =
                            { file = Nothing
                            , checksum = Nothing
                            , signedId = Nothing
                            , uploadUrl = Nothing
                            , previewUrl = Nothing
                            , headers = Nothing
                            , status = Waiting
                            , existingImageUrl = Nothing
                            , displayMenu = False
                            , railsId = Nothing
                            }
                    in
                    ( newModel, Cmd.none )

                Err _ ->
                    ( { model | status = FailDelete }, Cmd.none )

        DisplayMenu ->
            ( { model | displayMenu = True }, Cmd.none )

        HideMenu ->
            ( { model | displayMenu = False }, Cmd.none )


buildChecksumFromFile : File -> Task x String
buildChecksumFromFile file =
    Task.map buildChecksum (File.toBytes file)


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


requestUrl : Model -> Cmd Msg
requestUrl model =
    case ( model.file, model.checksum ) of
        ( Just file, Just checksum ) ->
            Http.post
                { url = "/rails/active_storage/direct_uploads"
                , body = Http.jsonBody (urlRequest file checksum)
                , expect = Http.expectJson GotUploadUrl urlDecoder
                }

        ( _, _ ) ->
            Cmd.none


buildRailsImage : Model -> Cmd Msg
buildRailsImage fileInfo =
    Http.post
        { url = "/user_profile_images"
        , body = Http.jsonBody (imageParams fileInfo)
        , expect = Http.expectJson ImageCreated imageDecoder
        }


uploadFile : Model -> Cmd Msg
uploadFile model =
    case ( model.uploadUrl, model.file, model.headers ) of
        ( Just uploadUrl, Just file, Just headers ) ->
            Http.request
                { method = "PUT"
                , url = uploadUrl
                , headers = headers
                , body = Http.fileBody file
                , expect = Http.expectWhatever UploadFinished
                , timeout = Nothing
                , tracker = Just (File.name file)
                }

        ( _, _, _ ) ->
            Cmd.none


deleteImage : Model -> Cmd Msg
deleteImage model =
    case model.railsId of
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


flagsDecoder : Decoder Model
flagsDecoder =
    map2
        (\url id ->
            { file = Nothing
            , checksum = Nothing
            , signedId = Nothing
            , uploadUrl = Nothing
            , previewUrl = Nothing
            , headers = Nothing
            , status = Waiting
            , existingImageUrl = Just url
            , displayMenu = False
            , railsId = Just id
            }
        )
        (field "url" string)
        (field "id" int)


imageDecoder : Decoder Int
imageDecoder =
    field "id" int


urlRequest : File -> String -> Encode.Value
urlRequest file checksum =
    Encode.object
        [ ( "blob"
          , Encode.object
                [ ( "filename", Encode.string (File.name file) )
                , ( "content_type", Encode.string (File.mime file) )
                , ( "byte_size", Encode.string (String.fromInt (File.size file)) )
                , ( "checksum", Encode.string checksum )
                ]
          )
        ]


imageParams : Model -> Encode.Value
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
    case ( model.status, model.file ) of
        ( Uploading _, Just file ) ->
            Http.track (File.name file) GotProgress

        ( _, _ ) ->
            Sub.none



-- MAIN


main : Program Encode.Value Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
