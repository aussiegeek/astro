defmodule AstroTest do
  use ExUnit.Case
  doctest Astro

  def near(val1, val2, margin \\ 0.000000000000001) do
    abs(val1 - val2) < margin
  end
    
  @date  %DateTime{calendar: Calendar.ISO, day: 5, hour: 0,  minute: 0,
                month: 3, second: 0, std_offset: 0, time_zone: "Etc/UTC", utc_offset: 0,
                year: 2013, zone_abbr: "UTC"}
  @lat 50.5
  @lng 30.5

  @testTimes %{
    dawn: "2013-03-05T04:02:17Z",
    nadir: "2013-03-04T22:10:57Z",
    solar_noon: "2013-03-05T10:10:57Z",
    sunrise: "2013-03-05T04:34:56Z",
    sunset: "2013-03-05T15:46:57Z",
    sunrise_end: "2013-03-05T04:38:19Z",
    sunset_start: "2013-03-05T15:43:34Z",
    dusk: "2013-03-05T16:19:36Z",
    nautical_dawn: "2013-03-05T03:24:31Z",
    nautical_dusk: "2013-03-05T16:57:22Z",
    night_end: "2013-03-05T02:46:17Z",
    night: "2013-03-05T17:35:36Z",
    golden_hour_end: "2013-03-05T05:19:01Z",
    golden_hour: "2013-03-05T15:02:52Z"
  }

  test "getPosition returns azimuth and altitude for the given time and location" do
    sunPos = Astro.get_position(@date, @lat, @lng)
    assert sunPos.azimuth == -2.5003175907168385
    assert sunPos.altitude == -0.7000406838781611
  end
  
  test "getTimes returns sun phases for the given date and location" do
     times = Astro.get_times(@date, @lat, @lng)

     iso8601_times = Enum.map(times, fn({k,v}) -> {k, Timex.format!(v, "{ISO:Extended:Z}")} end) |> Map.new
     assert iso8601_times == @testTimes
  end
end
