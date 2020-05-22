module ElmComponents.PostForm.Main exposing (..)

import Base64
import Browser
import Bytes exposing (Bytes)
import ElmComponents.PostForm.MD5 as MD5
import File exposing (File)
import File.Select as Select
import Hex.Convert
import Html exposing (Html, div, img, p, text)
import Html.Attributes exposing (class, src)
import Html.Events exposing (onClick)
import Http exposing (Header)
import Json.Decode exposing (Decoder, field, keyValuePairs, list, map, map3, string)
import Json.Encode as Encode
import Task exposing (Task)



-- MODEL


type alias Model =
    { status : AllUploadStatus
    , files : List FileWithInfo
    }


type alias FileIdentifyingInfo =
    { signedId : String, url : String, headers : List Header }


type alias FileWithChecksum =
    { file : File, checksum : String }


type alias FileWithInfo =
    { file : File
    , checksum : Maybe String
    , signedId : Maybe String
    , uploadUrl : Maybe String
    , previewUrl : Maybe String
    , headers : Maybe (List Header)
    , status : Status
    }


type Status
    = Waiting
    | Uploading Float
    | Done
    | Fail


type AllUploadStatus
    = AllWaiting
    | SomeUploading
    | AllDone



-- INIT


init : () -> ( Model, Cmd Msg )
init _ =
    ( { status = AllWaiting, files = [] }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    case model.status of
        AllWaiting ->
            div [ onClick SelectFiles, class "h-16 bg-gray-200 border-gray-500 border-dashed border text-center flex items-center justify-center" ] [ text "Upload Photos" ]

        SomeUploading ->
            renderPreviews model.files

        AllDone ->
            text "Upload complete!"


renderPreviews : List FileWithInfo -> Html Msg
renderPreviews files =
    div [ class "p-4 bg-gray-200 border-gray-500 border-dashed border flex flex-wrap" ] (List.map previewImage files)


previewImage : FileWithInfo -> Html Msg
previewImage file =
    case file.previewUrl of
        Just url ->
            div [ class "w-1/5 p-2" ] [ img [ src url ] [] ]

        Nothing ->
            div [ class "w-1/5 p-2" ] [ text "Loading" ]



-- MESSAGE


type Msg
    = GotUploadUrl FileWithInfo (Result Http.Error FileIdentifyingInfo)
    | GotFiles File (List File)
    | SelectFiles
    | ImageCreated (Result Http.Error ())
    | UploadFinished FileWithInfo (Result Http.Error ())
    | GotProgress FileWithInfo Http.Progress
    | GotPreviews (List FileWithInfo)
    | GotChecksums (List FileWithInfo)



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
        GotUploadUrl fileWithInfo result ->
            case result of
                Ok uploadUrl ->
                    let
                        originalFileWithInfoResult =
                            findMatchingFile model fileWithInfo
                    in
                    case originalFileWithInfoResult of
                        Nothing ->
                            ( model, Cmd.none )

                        Just originalFileWithInfo ->
                            let
                                updatedFileWithInfo =
                                    updateFileWithInfoWithUrlUploadInfo originalFileWithInfo uploadUrl

                                newModel =
                                    replaceExistingFileWithInfo model updatedFileWithInfo
                            in
                            ( newModel, uploadFile updatedFileWithInfo )

                Err _ ->
                    ( model, Cmd.none )

        GotFiles file files ->
            let
                selectedFiles =
                    file :: files

                selectedFilesWithInfo =
                    List.map (\plainFile -> FileWithInfo file Nothing Nothing Nothing Nothing Nothing Waiting) selectedFiles

                filesPreviewUrlRequests =
                    Task.sequence <| List.map addFilePreviewUrl selectedFilesWithInfo

                filesChecksumRequests =
                    Task.sequence <| List.map addChecksumToFileWithInfo selectedFilesWithInfo
            in
            ( { model | files = selectedFilesWithInfo, status = SomeUploading }
            , Cmd.batch [ Task.perform GotChecksums filesChecksumRequests, Task.perform GotPreviews filesPreviewUrlRequests ]
            )

        GotPreviews filesWithInfoAndPreviewUrls ->
            let
                newModel =
                    List.foldl addPreviewUrlToExistingFileWithInfo model filesWithInfoAndPreviewUrls
            in
            ( newModel, Cmd.none )

        GotChecksums filesWithNewInfoChecksums ->
            let
                newModel =
                    List.foldl addChecksumToExistingFileWithInfo model filesWithNewInfoChecksums
            in
            ( newModel, fetchUploadUrls filesWithNewInfoChecksums )

        GotProgress fileWithInfo progress ->
            case progress of
                Http.Sending p ->
                    let
                        newStatus =
                            Uploading (Http.fractionSent p)

                        newModel =
                            addStatusToExistingFileWithInfo { fileWithInfo | status = newStatus } model
                    in
                    ( newModel, Cmd.none )

                Http.Receiving _ ->
                    ( model, Cmd.none )

        SelectFiles ->
            ( model, Select.files [ "image/*" ] GotFiles )

        UploadFinished fileWithInfo result ->
            ( model, buildRailsImage fileWithInfo )

        ImageCreated result ->
            ( { model | status = AllDone }, Cmd.none )


addChecksumToExistingFileWithInfo : FileWithInfo -> Model -> Model
addChecksumToExistingFileWithInfo fileWithChecksum existingModel =
    let
        possibleFileToUpdate =
            findMatchingFile existingModel fileWithChecksum
    in
    case possibleFileToUpdate of
        Nothing ->
            existingModel

        Just fileToUpdate ->
            replaceExistingFileWithInfo existingModel { fileToUpdate | checksum = fileWithChecksum.checksum }


addStatusToExistingFileWithInfo : FileWithInfo -> Model -> Model
addStatusToExistingFileWithInfo fileWithStatus existingModel =
    let
        possibleFileToUpdate =
            findMatchingFile existingModel fileWithStatus
    in
    case possibleFileToUpdate of
        Nothing ->
            existingModel

        Just fileToUpdate ->
            replaceExistingFileWithInfo existingModel { fileToUpdate | status = fileWithStatus.status }


addPreviewUrlToExistingFileWithInfo : FileWithInfo -> Model -> Model
addPreviewUrlToExistingFileWithInfo fileWithPreviewUrl existingModel =
    let
        possibleFileToUpdate =
            findMatchingFile existingModel fileWithPreviewUrl
    in
    case possibleFileToUpdate of
        Nothing ->
            existingModel

        Just fileToUpdate ->
            replaceExistingFileWithInfo existingModel { fileToUpdate | previewUrl = fileWithPreviewUrl.previewUrl }


replaceExistingFileWithInfo : Model -> FileWithInfo -> Model
replaceExistingFileWithInfo model fileWithInfo =
    let
        ( matchingFiles, nonMatchingfiles ) =
            List.partition (fileMatches fileWithInfo) model.files
    in
    if List.isEmpty matchingFiles then
        model

    else
        { model | files = fileWithInfo :: nonMatchingfiles }


findMatchingFile : Model -> FileWithInfo -> Maybe FileWithInfo
findMatchingFile model fileWithInfo =
    let
        ( matchingFiles, _ ) =
            List.partition (fileMatches fileWithInfo) model.files
    in
    List.head matchingFiles


fileMatches : FileWithInfo -> FileWithInfo -> Bool
fileMatches file1 file2 =
    (File.name file1.file == File.name file2.file) && (File.size file1.file == File.size file2.file)


updateFileWithNewInfo : FileWithInfo -> Model -> Model
updateFileWithNewInfo updatedFileWithInfo oldModel =
    let
        ( matchingFiles, nonMatchingfiles ) =
            List.partition (fileMatches updatedFileWithInfo) oldModel.files
    in
    if List.isEmpty matchingFiles then
        oldModel

    else
        { oldModel | files = updatedFileWithInfo :: nonMatchingfiles }


setUrl : FileWithInfo -> String -> FileWithInfo
setUrl fileWithInfo newUrl =
    { fileWithInfo | previewUrl = Just newUrl }


setChecksum : FileWithInfo -> String -> FileWithInfo
setChecksum fileWithInfo checksum =
    { fileWithInfo | checksum = Just checksum }


addChecksumToFileWithInfo : FileWithInfo -> Task x FileWithInfo
addChecksumToFileWithInfo fileWithInfo =
    let
        md5 =
            Task.map buildChecksum (File.toBytes fileWithInfo.file)
    in
    Task.map (setChecksum fileWithInfo) md5


addFilePreviewUrl : FileWithInfo -> Task x FileWithInfo
addFilePreviewUrl fileWithInfo =
    Task.map (setUrl fileWithInfo) (File.toUrl fileWithInfo.file)


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


fetchUploadUrls : List FileWithInfo -> Cmd Msg
fetchUploadUrls files =
    Cmd.batch <| List.map requestUrl files


requestUrl : FileWithInfo -> Cmd Msg
requestUrl file =
    Http.post
        { url = "/rails/active_storage/direct_uploads"
        , body = Http.jsonBody (urlRequest file)
        , expect = Http.expectJson (GotUploadUrl file) urlDecoder
        }


buildRailsImage : FileWithInfo -> Cmd Msg
buildRailsImage fileInfo =
    Http.post
        { url = "/images"
        , body = Http.jsonBody (imageParams fileInfo)
        , expect = Http.expectWhatever ImageCreated
        }


uploadFile : FileWithInfo -> Cmd Msg
uploadFile fileWithInfo =
    Http.request
        { method = "PUT"
        , url = Maybe.withDefault "" fileWithInfo.uploadUrl
        , headers = Maybe.withDefault [] fileWithInfo.headers
        , body = Http.fileBody fileWithInfo.file
        , expect = Http.expectWhatever (UploadFinished fileWithInfo)
        , timeout = Nothing
        , tracker = Just (File.name fileWithInfo.file)
        }


urlDecoder : Decoder FileIdentifyingInfo
urlDecoder =
    map3 FileIdentifyingInfo
        (field "signed_id" string)
        (field "direct_upload" (field "url" string))
        (field "direct_upload" (field "headers" (keyValuePairs string))
            |> map (List.map (\( a, b ) -> Http.header a b))
        )


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
    case model.status of
        SomeUploading ->
            let
                filesWithInfo =
                    model.files

                trackers =
                    List.map (\fileWithInfo -> Http.track (File.name fileWithInfo.file) (GotProgress fileWithInfo)) filesWithInfo
            in
            Sub.batch trackers

        _ ->
            Sub.none



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
