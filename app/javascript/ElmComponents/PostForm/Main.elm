module ElmComponents.PostForm.Main exposing (..)

import Browser
import File exposing (File)
import File.Select as Select
import Html exposing (Html, div, img, p, text)
import Html.Attributes exposing (class, src)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, field, string)
import Json.Encode as Encode
import Task



-- MODEL


type alias Model =
    { status : Status
    , files : List File
    , uploadUrls : List UploadUrl
    , previewUrls : List String
    }


type alias UploadUrl =
    { url : String }


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
    = GotUrl (Result Http.Error String)
    | GotFiles File (List File)
    | SelectFiles
    | GotProgress Http.Progress
    | GotPreviews (List String)



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotUrl result ->
            case result of
                Ok url ->
                    let
                        newUrl =
                            UploadUrl url

                        newUploadUrls =
                            newUrl :: model.uploadUrls
                    in
                    ( { model | uploadUrls = newUploadUrls }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        GotFiles file files ->
            let
                selectedFiles =
                    file :: files

                previewUrls =
                    Task.sequence <| List.map File.toUrl selectedFiles
            in
            ( { model | files = selectedFiles, status = Uploading 0 }, Cmd.batch [ fetchUrls selectedFiles, Task.perform GotPreviews previewUrls ] )

        GotPreviews urls ->
            ( { model | previewUrls = urls }, Cmd.none )

        GotProgress progress ->
            ( model, Cmd.none )

        SelectFiles ->
            ( model, Select.files [ "image/*" ] GotFiles )


fetchUrls : List File -> Cmd Msg
fetchUrls files =
    Cmd.batch <| List.map requestUrl files


requestUrl : File -> Cmd Msg
requestUrl file =
    Http.post
        { url = "/rails/active_storage/direct_uploads"
        , body = Http.jsonBody (urlRequest file)
        , expect = Http.expectJson GotUrl urlDecoder
        }


urlDecoder : Decoder String
urlDecoder =
    field "direct_upload" (field "url" string)


urlRequest : File -> Encode.Value
urlRequest file =
    Encode.object
        [ ( "blob"
          , Encode.object
                [ ( "filename", Encode.string (File.name file) )
                , ( "content_type", Encode.string (File.mime file) )
                , ( "byte_size", Encode.string (String.fromInt (File.size file)) )
                , ( "checksum", Encode.string "123" )
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
