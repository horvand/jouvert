%%% @doc Calculate the date of Trinidad Carnival
-module(jouvert).

-export([countdown/0,
         jouvert/0,
         jouvert/1,
         easter/1,
         %% easter_test/0,

         %% Make module usable as an escript
         main/1,
         format_daystime/1
        ]).

%% for testing
-export([jouvert_after/1, daystime_diff/2]).

%% Types not exported from the `calendar' module
-type days() :: 0..366.
-type year() :: 1970..10000.

%% @doc Time to wait till next year's carnival opens
-spec countdown() -> {days(), calendar:time()}.
countdown() ->
    UTCNow = calendar:universal_time(),
    Jouvert = jouvert_after(UTCNow),
	daystime_diff(Jouvert, UTCNow).

%% @doc Calculate difference between two dates
-spec daystime_diff(calendar:datetime(), calendar:datetime()) ->
                           {days(), calendar:time()}.
daystime_diff(Later, Earlier) ->
    calendar:seconds_to_daystime(
      calendar:datetime_to_gregorian_seconds(Later)
      - calendar:datetime_to_gregorian_seconds(Earlier)).

%% @doc Date and time of the coming J'ouvert
-spec jouvert() -> calendar:datetime().
jouvert() ->
    UTCNow = calendar:universal_time(),
	jouvert_after(UTCNow).

%% @doc Date of the coming J'ouvert after a given date
-spec jouvert_after(calendar:datetime()) -> calendar:datetime().
jouvert_after({{Year, _M, _D}, _Time} = DateTime) ->
    case jouvert(Year) of
		Jouvert when DateTime < Jouvert ->
            Jouvert;
		_Passed ->
			jouvert(Year + 1)
    end.

%% @doc Calculate the start of J'overt in the given year
%%
%% The date for J'ouvert is the Monday before Ash Wednesday,
%% 48 days before Easter Sunday.
-spec jouvert(year()) -> calendar:datetime().
jouvert(Year) ->
    Easter = easter(Year),
    JouvertMon = days_before(Easter, 48),
    {JouvertMon, jouvert_time()}.

%% @doc Start time of J'ouvert in UTC
%%
%% this is a constant function.
%% 4:00am Trinidad time(-4:00) is 8:00 UTC.
-spec jouvert_time() -> calendar:time().
jouvert_time() ->
    {8, 0, 0}. %% in UTC

%% @doc Subtract a number of days from a date
-spec days_before(calendar:date(), days()) -> calendar:datetime().
days_before(Date, Days) ->
    GD = calendar:date_to_gregorian_days(Date),
    calendar:gregorian_days_to_date(GD - Days).

%% @doc Easter date calculation
%%
%% @see http://en.wikipedia.org/wiki/Computus
%% @see https://www.drupal.org/node/1180480
-spec easter(year()) -> calendar:date().
easter(Year) ->
    A = Year rem 19,
    B = Year div 100,
    C = Year rem 100,
    D = B div 4,
    E = B rem 4,
    F = (B + 8) div 25,
    G = (B - F + 1) div 3,
    H = (19 * A + B - D - G + 15) rem 30,
    I = C div 4,
    K = C rem 4,
    L = (32 + 2 * E + 2 * I - H - K) rem 7,
    M = (A + 11 * H + 22 * L) div 451,
    Month = (H + L - 7 * M + 114) div 31,
    Day = (H + L - 7 * M + 114) rem 31 + 1,
    {Year, Month, Day}.

%%% Functions for standalone use

%% @doc Escript entry point
-spec main([string()]) -> no_return().
main(_) ->
    io:format("~s till J'ouvert\n",
              [format_daystime(countdown())]).

%% @doc Format a {Days, Time} tuple as English text
-spec format_daystime({days(), calendar:time()}) -> iolist().
format_daystime({Days, {H, M, S}}) ->
    io_lib:format("~w day~s and ~w:~2..0w:~2..0w",
                  [Days, case Days of 1 -> ""; _ -> "s" end, H, M, S]).

%% Computus test. OK.
%%
%% easter_test() ->
%%     lists:foreach(fun ({Y, _M, _D} = Easter) ->
%%                           Easter = easter(Y)
%%                   end, easter_data()),
%%     ok.
%%
%% %% easter_data() ->
%%     [{2015, 4, 5},
%%      {2016, 3, 27},
%%      {2017, 4, 16},
%%      {2018, 4, 1},
%%      {2019, 4, 21},
%%      {2020, 4, 12},
%%      {2021, 4, 4},
%%      {2022, 4, 17},
%%      {2023, 4, 9},
%%      {2024, 3, 31},
%%      {2025, 4, 20},
%%      {2026, 4, 5},
%%      {2027, 3, 28},
%%      {2028, 4, 16},
%%      {2029, 4, 1},
%%      {2030, 4, 21},
%%      {2031, 4, 13},
%%      {2032, 3, 28},
%%      {2033, 4, 17},
%%      {2034, 4, 9},
%%      {2035, 3, 25}].
