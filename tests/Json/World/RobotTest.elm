module Json.World.RobotTest exposing (robotFuzzer, suite)

import Expect
import Fuzz exposing (Fuzzer)
import Json.Decode as Decode
import Json.World.GPS.DirectionTest exposing (directionFuzzer)
import Json.World.GPS.LocationTest exposing (locationFuzzer)
import Json.World.Robot as Robot
import Test exposing (Test, describe, fuzz, test)
import World.GPS.Direction exposing (Direction(..))
import World.GPS.Location exposing (location)
import World.Robot exposing (Robot, execute, robot)
import World.Robot.Instruction exposing (Instruction(..))


suite : Test
suite =
    describe "Robot"
        [ describe "execute"
            [ describe "forward"
                [ test "facing North" <|
                    \_ ->
                        let
                            expected =
                                location 0 1
                                    |> robot North

                            result =
                                location 0 0
                                    |> robot North
                                    |> execute Forward
                        in
                        Expect.equal expected result
                , test "facing East" <|
                    \_ ->
                        let
                            expected =
                                location 1 0
                                    |> robot East

                            result =
                                location 0 0
                                    |> robot East
                                    |> execute Forward
                        in
                        Expect.equal expected result
                , test "facing South" <|
                    \_ ->
                        let
                            expected =
                                location 0 -1
                                    |> robot South

                            result =
                                location 0 0
                                    |> robot South
                                    |> execute Forward
                        in
                        Expect.equal expected result
                , test "facing West" <|
                    \_ ->
                        let
                            expected =
                                location -1 0
                                    |> robot West

                            result =
                                location 0 0
                                    |> robot West
                                    |> execute Forward
                        in
                        Expect.equal expected result
                , describe "right"
                    [ test "facing North" <|
                        \_ ->
                            let
                                expected =
                                    location 0 0
                                        |> robot East

                                result =
                                    location 0 0
                                        |> robot North
                                        |> execute Right
                            in
                            Expect.equal expected result
                    , test "facing East" <|
                        \_ ->
                            let
                                expected =
                                    location 0 0
                                        |> robot South

                                result =
                                    location 0 0
                                        |> robot East
                                        |> execute Right
                            in
                            Expect.equal expected result
                    , test "facing South" <|
                        \_ ->
                            let
                                expected =
                                    location 0 0
                                        |> robot West

                                result =
                                    location 0 0
                                        |> robot South
                                        |> execute Right
                            in
                            Expect.equal expected result
                    , test "facing West" <|
                        \_ ->
                            let
                                expected =
                                    location 0 0
                                        |> robot North

                                result =
                                    location 0 0
                                        |> robot West
                                        |> execute Right
                            in
                            Expect.equal expected result
                    ]
                , describe "left"
                    [ test "facing North" <|
                        \_ ->
                            let
                                expected =
                                    location 0 0
                                        |> robot West

                                result =
                                    location 0 0
                                        |> robot North
                                        |> execute Left
                            in
                            Expect.equal expected result
                    , test "facing East" <|
                        \_ ->
                            let
                                expected =
                                    location 0 0
                                        |> robot North

                                result =
                                    location 0 0
                                        |> robot East
                                        |> execute Left
                            in
                            Expect.equal expected result
                    , test "facing South" <|
                        \_ ->
                            let
                                expected =
                                    location 0 0
                                        |> robot East

                                result =
                                    location 0 0
                                        |> robot South
                                        |> execute Left
                            in
                            Expect.equal expected result
                    , test "facing West" <|
                        \_ ->
                            let
                                expected =
                                    location 0 0
                                        |> robot South

                                result =
                                    location 0 0
                                        |> robot West
                                        |> execute Left
                            in
                            Expect.equal expected result
                    ]
                ]
            ]
        , describe "decode"
            [ test "decode a robot" <|
                \_ ->
                    let
                        expected =
                            location 0 0
                                |> robot North
                                |> Ok

                        actual =
                            """{"location": {"x": 0, "y": 0}, "direction": "North"}"""
                                |> Decode.decodeString Robot.decode
                    in
                    Expect.equal expected actual
            , fuzz robotFuzzer "encode decode are inverses" <|
                \aRobot ->
                    let
                        expected =
                            aRobot
                                |> Ok

                        actual =
                            aRobot
                                |> Robot.encode
                                |> Decode.decodeValue Robot.decode
                    in
                    Expect.equal expected actual
            ]
        ]


robotFuzzer : Fuzzer Robot
robotFuzzer =
    Fuzz.map2 robot directionFuzzer locationFuzzer
