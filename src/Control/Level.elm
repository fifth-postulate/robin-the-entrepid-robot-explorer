module Control.Level exposing (Level, decode, encode, level, name, process, view)

import Control.CAN as CAN
import Html exposing (Html)
import Http exposing (Error(..))
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode
import World exposing (World)


type Level
    = Level
        { index : Int
        , world : World
        }


level : Int -> World -> Level
level index aWorld =
    Level
        { index = index
        , world = aWorld
        }


encode : Level -> Encode.Value
encode (Level aLevel) =
    Encode.object
        [ ( "index", Encode.int aLevel.index )
        , ( "world", World.encode aLevel.world )
        ]


decode : Decoder Level
decode =
    Decode.succeed level
        |> required "index" Decode.int
        |> required "world" World.decode


view : Level -> Html msg
view (Level aLevel) =
    Html.div []
        [ World.view aLevel.world
        ]


name : Int -> String
name index =
    let
        prefix =
            if index < 10 then
                "0"

            else
                ""
    in
    prefix ++ String.fromInt index


process : String -> Level -> Level
process source (Level aLevel) =
    case CAN.parse source of
        Ok instructions ->
            case World.executeAll instructions aLevel.world of
                Ok nextWorld ->
                    Level { aLevel | world = nextWorld }

                Err _ ->
                    -- TODO error handling
                    Level aLevel

        Err _ ->
            -- TODO error handling
            Level aLevel
