#! /bin/bash
./rebar co && erl -pa ebin deps/*/ebin -s gomoku_app