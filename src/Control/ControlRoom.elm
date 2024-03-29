module Control.ControlRoom exposing (ControlRoom, Msg(..), controlRoom, update, view)

import Control.CAN as CAN
import Control.Level as Level exposing (Level)
import Css exposing (..)
import Editor exposing (Editor)
import EditorMsg exposing (WrapOption(..))
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attribute
import Html.Styled.Events as Event


type ControlRoom
    = ControlRoom
        { level : Level
        , editor : Editor
        }


controlRoom : Level -> ControlRoom
controlRoom aLevel =
    ControlRoom
        { level = aLevel
        , editor =
            Editor.initWithContent "Forward"
                { width = 640
                , height = 640
                , fontSize = 16
                , verticalScrollOffset = 3
                , debugOn = False
                , wrapOption = DontWrap
                }
        }


type Msg
    = EditorMsg EditorMsg.EMsg
    | Load
    | LevelMsg Level.Msg


update : Msg -> ControlRoom -> ( ControlRoom, Cmd Msg )
update message (ControlRoom aControlRoom) =
    case message of
        EditorMsg editorMessage ->
            let
                ( editor, cmd ) =
                    Editor.update editorMessage aControlRoom.editor
            in
            ( ControlRoom { aControlRoom | editor = editor }, Cmd.map EditorMsg cmd )

        LevelMsg levelMessage ->
            let
                ( aLevel, cmd ) =
                    Level.update levelMessage aControlRoom.level
            in
            ( ControlRoom { aControlRoom | level = aLevel }, Cmd.map LevelMsg cmd )

        Load ->
            let
                source =
                    Editor.getContent aControlRoom.editor

                instructions =
                    case CAN.parse source of
                        Ok ins ->
                            ins

                        Err _ ->
                            []
            in
            ( ControlRoom { aControlRoom | level = Level.load instructions aControlRoom.level }, Cmd.none )


view : ControlRoom -> List (Html Msg)
view (ControlRoom aControlRoom) =
    [ Html.h1 [] [ Html.text "Control" ]
    , Html.div [ Attribute.css [ displayFlex, flexDirection row, flexWrap noWrap, justifyContent flexStart, alignItems flexStart ] ]
        [ Level.view aControlRoom.level |> Html.map LevelMsg
        , Html.div [ Attribute.css [ displayFlex, flexDirection column, flexWrap noWrap, justifyContent flexStart, alignItems flexStart ] ]
            [ Html.button [ Event.onClick Load ] [ Html.text "load" ]
            , Editor.view aControlRoom.editor |> Html.fromUnstyled |> Html.map EditorMsg
            ]
        ]
    ]
