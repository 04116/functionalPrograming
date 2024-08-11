module Main exposing (main)

import Browser
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (disabled, style)
import Html.Events exposing (onClick)


type Player
    = X
    | O


type alias GameState =
    -- Maybe here cause when init, board is empty
    { board : List (Maybe Player)
    , currentPlayer : Player
    }


{-| Model include all data need to be use for render game UI/UX
-}
type alias Model =
    { current : GameState
    , past : List GameState
    , future : List GameState
    }


type
    Msg
    -- for play the game
    -- now it only Click on the cell
    = CellClicked Int
      -- for history control
    | Undo
    | Redo


init : Model
init =
    { -- init board with empty
      current =
        { board = List.repeat 9 Nothing

        -- must set current player
        , currentPlayer = X
        }
    , past = []
    , future = []
    }


view : Model -> Html Msg
view model =
    div
        [ style "display" "flex"
        , style "flex-direction" "column"
        , style "align-items" "center"
        , style "justify-content" "center"
        , style "height" "100vh"
        , style "font-family" "Arial, sans-serif"
        ]
        [ viewBoard model.current
        , viewButtons model
        ]


viewBoard : GameState -> Html Msg
viewBoard gameState =
    div
        [ style "display" "grid"
        , style "grid-template-columns" "repeat(3, 100px)"
        , style "grid-template-rows" "repeat(3, 100px)"
        , style "gap" "5px"
        , style "background-color" "black"
        , style "width" "310px"
        , style "height" "310px"
        , style "padding" "5px"
        , style "margin-bottom" "20px"
        ]
        -- each time board (list of cell) change, we want to view it
        (List.indexedMap viewCell gameState.board)


viewButton : String -> Msg -> Bool -> Html Msg
viewButton label msg isDisabled =
    button
        [ onClick msg
        , disabled isDisabled
        , style "padding" "10px 20px"
        , style "font-size" "16px"
        , style "cursor"
            (if isDisabled then
                "not-allowed"

             else
                "pointer"
            )
        , style "opacity"
            (if isDisabled then
                "0.6"

             else
                "1"
            )
        , style "transition" "opacity 0.3s"
        ]
        [ text label ]


viewButtons : Model -> Html Msg
viewButtons model =
    div
        [ style "display" "flex"
        , style "justify-content" "center"
        , style "gap" "10px"
        ]
        [ viewButton "Undo" Undo (List.isEmpty model.past)
        , viewButton "Redo" Redo (List.isEmpty model.future)
        ]


viewCell : Int -> Maybe Player -> Html Msg
viewCell index cellValue =
    div
        [ style "background-color" "white"
        , style "display" "flex"
        , style "justify-content" "center"
        , style "align-items" "center"
        , style "font-size" "40px"
        , style "cursor" "pointer"
        , onClick (CellClicked index)
        ]
        [ text (cellToString cellValue) ]


cellToString : Maybe Player -> String
cellToString cell =
    case cell of
        Just X ->
            "X"

        Just O ->
            "O"

        Nothing ->
            ""


historyToBoard : List Int -> List (Maybe Player)
historyToBoard history =
    []


update : Msg -> Model -> Model
update msg model =
    case msg of
        CellClicked index ->
            if isValidMove model.current index then
                let
                    newGameState =
                        { board = updateBoard model.current.board index model.current.currentPlayer
                        , currentPlayer = nextPlayer model.current.currentPlayer
                        }
                in
                { model
                    | current = newGameState
                    , past = model.current :: model.past
                    , future = []
                }

            else
                model

        Undo ->
            case model.past of
                prevState :: remainingPast ->
                    { model
                        | current = prevState
                        , past = remainingPast
                        , future = model.current :: model.future
                    }

                [] ->
                    model

        Redo ->
            case model.future of
                nextState :: remainingFuture ->
                    { model
                        | current = nextState
                        , past = model.current :: model.past
                        , future = remainingFuture
                    }

                [] ->
                    model


{-| check that not yet have a move at cell (identify by index, from 0-8)
index [0:8] cause we have 3x3 matrix
-}
isValidMove : GameState -> Int -> Bool
isValidMove gameState index =
    -- here how we get value at index of a List :))
    -- can not use List.member here cause index is Int not a Maybe Player
    -- no way to cast Int to Maybe Player
    case List.drop index gameState.board |> List.head of
        Just Nothing ->
            True

        _ ->
            False


updateBoard : List (Maybe Player) -> Int -> Player -> List (Maybe Player)
updateBoard board index player =
    List.indexedMap
        (\i cell ->
            if i == index then
                Just player

            else
                cell
        )
        board


nextPlayer : Player -> Player
nextPlayer currentPlayer =
    case currentPlayer of
        X ->
            O

        O ->
            X


main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }
