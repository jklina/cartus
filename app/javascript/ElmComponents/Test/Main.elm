module ElmComponents.Test.Main exposing (..)

import Browser
import Html exposing (Html, h1, img, text)
import Html.Attributes exposing (class, src)



-- MODEL


type alias Model =
    { previewUrl : String }



-- INIT


init : String -> ( Model, Cmd Message )
init previewUrl =
    ( { previewUrl = previewUrl }, Cmd.none )



-- VIEW


view : Model -> Html Message
view model =
    img [ src model.previewUrl, class "rounded-t" ] []



-- MESSAGE


type Message
    = None



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.none



-- MAIN


main : Program String Model Message
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
