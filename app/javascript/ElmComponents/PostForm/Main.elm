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
import Json.Decode exposing (Decoder, field, keyValuePairs, list, map, map2, string)
import Json.Encode as Encode
import Task exposing (Task)



-- MODEL


type alias Model =
    { status : Status
    , files : List FileWithChecksum
    , uploadUrls : List UploadUrl
    , previewUrls : List String
    }


type alias UploadUrl =
    { url : String, headers : List Header }


type alias FileWithChecksum =
    { file : File, checksum : String }


type Status
    = Waiting
    | Uploading Float
    | Done
    | Fail



-- INIT


init : () -> ( Model, Cmd Msg )
init _ =
    ( { status = Waiting, files = [], uploadUrls = [], previewUrls = [] }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    case model.status of
        Waiting ->
            div [ onClick SelectFiles, class "h-16 bg-gray-200 border-gray-500 border-dashed border text-center flex items-center justify-center" ] [ text "Upload Photos" ]

        Uploading progress ->
            renderPreviews model.previewUrls

        Done ->
            text "Upload complete!"

        Fail ->
            text "Failed"


renderPreviews : List String -> Html Msg
renderPreviews urls =
    div [ class "p-4 bg-gray-200 border-gray-500 border-dashed border flex flex-wrap" ] (List.map previewImage urls)


previewImage : String -> Html Msg
previewImage url =
    img [ src url, class "w-1/5 p-2" ] []



-- MESSAGE


type Msg
    = GotUrl File (Result Http.Error UploadUrl)
    | GotFiles File (List File)
    | SelectFiles
    | UploadFinished (Result Http.Error String)
    | GotProgress Http.Progress
    | GotPreviews (List String)
    | GotFileStrings (List FileWithChecksum)



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotUrl file result ->
            case result of
                Ok url ->
                    let
                        newUrl =
                            url

                        newUrls =
                            url :: model.uploadUrls
                    in
                    ( { model | uploadUrls = newUrls }, uploadFile file newUrl )

                Err _ ->
                    ( model, Cmd.none )

        GotFiles file files ->
            let
                selectedFiles =
                    file :: files

                previewUrls =
                    Task.sequence <| List.map File.toUrl selectedFiles

                fileStringsRequests =
                    Task.sequence <| List.map buildFileWithChecksum selectedFiles
            in
            ( { model | status = Uploading 0 }, Cmd.batch [ Task.perform GotFileStrings fileStringsRequests, Task.perform GotPreviews previewUrls ] )

        GotFileStrings filesWithChecksum ->
            ( model, fetchUrls filesWithChecksum )

        GotPreviews urls ->
            ( { model | previewUrls = urls }, Cmd.none )

        GotProgress progress ->
            ( model, Cmd.none )

        SelectFiles ->
            ( model, Select.files [ "image/*" ] GotFiles )

        UploadFinished result ->
            ( model, Select.files [ "image/*" ] GotFiles )


buildFileWithChecksum : File -> Task x FileWithChecksum
buildFileWithChecksum file =
    let
        md5 =
            Task.map buildChecksum (File.toBytes file)
    in
    Task.map (FileWithChecksum file) md5


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


fetchUrls : List FileWithChecksum -> Cmd Msg
fetchUrls files =
    Cmd.batch <| List.map requestUrl files


requestUrl : FileWithChecksum -> Cmd Msg
requestUrl file =
    Http.post
        { url = "/rails/active_storage/direct_uploads"
        , body = Http.jsonBody (urlRequest file)
        , expect = Http.expectJson (GotUrl file.file) urlDecoder
        }


uploadFile : File -> UploadUrl -> Cmd Msg
uploadFile file url =
    Http.request
        { method = "PUT"
        , url = url.url
        , headers = url.headers
        , body = Http.fileBody file
        , expect = Http.expectJson UploadFinished string
        , timeout = Nothing
        , tracker = Just "upload"
        }


urlDecoder : Decoder UploadUrl
urlDecoder =
    map2 UploadUrl
        (field "direct_upload" (field "url" string))
        (field "direct_upload" (field "headers" (keyValuePairs string))
            |> map (List.map (\( a, b ) -> Http.header a b))
        )


urlRequest : FileWithChecksum -> Encode.Value
urlRequest fileWithChecksum =
    Encode.object
        [ ( "blob"
          , Encode.object
                [ ( "filename", Encode.string (File.name fileWithChecksum.file) )
                , ( "content_type", Encode.string (File.mime fileWithChecksum.file) )
                , ( "byte_size", Encode.string (String.fromInt (File.size fileWithChecksum.file)) )
                , ( "checksum", Encode.string fileWithChecksum.checksum )
                ]
          )
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
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
