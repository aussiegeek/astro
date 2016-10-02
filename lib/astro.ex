defmodule Astro do
  @moduledoc "Library to calculate sunrise/set and related times given a latitude and longitude"
  # ported from https://github.com/mourner/suncalc
  # sun calculations are based on http://aa.quae.nl/en/reken/zonpositie.html formulas
  # date/time constants and conversions

  @day_ms 1000 *  60 * 60 * 24
  @j1970 2440588
  @j2000 2451545

  defp to_julian(date), do: DateTime.to_unix(date, :milliseconds) / @day_ms - 0.5 + @j1970
  defp from_julian(j) do
    {:ok, dt} = DateTime.from_unix(round((j + 0.5 - @j1970) * @day_ms), :milliseconds)
    %{dt | microsecond: {0,0}}
  end
  defp to_days(date), do: to_julian(date) - @j2000


  # general calculations for position
  @pi :math.pi
  @rad :math.pi / 180
  @e @rad * 23.4397 # obliquity of the Earth
  
  defp right_ascension(l, b), do: :math.atan2(:math.sin(l) * :math.cos(@e) - :math.tan(b) * :math.sin(@e), :math.cos(l))
  defp declination(l, b), do: :math.asin(:math.sin(b) * :math.cos(@e) + :math.cos(b) * :math.sin(@e) * :math.sin(l))
  
  defp azimuth(h, phi, dec), do: :math.atan2(:math.sin(h), :math.cos(h) * :math.sin(phi) - :math.tan(dec) * :math.cos(phi))
  defp altitude(h, phi, dec), do: :math.asin(:math.sin(phi) * :math.sin(dec) + :math.cos(phi) * :math.cos(dec) * :math.cos(h))

  defp sidereal_time(d, lw), do: @rad * (280.16 + 360.9856235 * d) - lw

  defp astro_refraction(h) when h <0, do: 0 #works for positive altitudes only
  defp astro_refraction(h) do
    # formula 16.4 of "Astronomical Algorithms" 2nd edition by Jean Meeus (Willmann-Bell, Richmond) 1998.
    # 1.02 / tan(h + 10.26 / (h + 5.10)) h in degrees, result in arc minutes -> converted to rad:
    0.0002967 / :math.tan(h + 0.00312536 / (h + 0.08901179))
  end

  # general sun calculations

  defp solar_mean_anomaly(d), do: @rad * (357.5291 + 0.98560028 * d)

  defp ecliptic_longitude(m) do
    c = @rad * (1.9148 * :math.sin(m) + 0.02 * :math.sin(2 * m) + 0.0003 * :math.sin(3 * m)) # equation of center
    p = @rad * 102.9372 # perihelion of the Earth

    m + c + p + @pi
  end

  defp sun_coords(d) do
    m = solar_mean_anomaly(d)
    l = ecliptic_longitude(m)

    %{
      dec: declination(l, 0),
      ra: right_ascension(l, 0)
    }
  end

  # calculates sun position for a given date and latitude/longitude

  def get_position(date, lat, lng) do
    lw  = @rad * -lng
    phi = @rad * lat
    d   = to_days(date)

    c  = sun_coords(d)
    h  = sidereal_time(d, lw) - c.ra

    %{
        azimuth: azimuth(h, phi, c.dec),
        altitude: altitude(h, phi, c.dec)
    }
  end


  # sun times configuration (angle, morning name, evening name)

  @times [
    [-0.833, "sunrise",         "sunset"       ],
    [  -0.3, "sunrise_end",     "sunset_start" ],
    [    -6, "dawn",            "dusk"         ],
    [   -12, "nautical_dawn",   "nautical_dusk"],
    [   -18, "night_end",       "night"        ],
    [     6, "golden_hour_end", "golden_hour"  ]
  ]


  # calculations for sun times

  @j0 0.0009

  defp julian_cycle(d, lw), do: Float.round(d - @j0 - lw / (2 * @pi))

  defp approx_transit(ht, lw, n), do: @j0 + (ht + lw) / (2 * @pi) + n
  defp solar_transit_j(ds, m, l), do: @j2000 + ds + 0.0053 * :math.sin(m) - 0.0069 * :math.sin(2 * l)

  defp hour_angle(h, phi, d), do: :math.acos((:math.sin(h) - :math.sin(phi) * :math.sin(d)) / (:math.cos(phi) * :math.cos(d)))

  # returns set time for the given sun altitude
  defp get_set_j(h, lw, phi, dec, n, m, l) do
    w = hour_angle(h, phi, dec)
    a = approx_transit(w, lw, n)
    solar_transit_j(a, m, l)
  end


  # calculates sun times for a given date and latitude/longitude
  def get_times(lat, lng), do: get_times(DateTime.utc_now, lat, lng)
  def get_times(date, lat, lng) do
    lw = @rad * -lng
    phi = @rad * lat

    d = to_days(date)
    n = julian_cycle(d, lw)
    ds = approx_transit(0, lw, n)

    m = solar_mean_anomaly(ds)
    l = ecliptic_longitude(m)
    dec = declination(l, 0)

    j_noon = solar_transit_j(ds, m, l)

    result = %{
      solar_noon: from_julian(j_noon),
      nadir: from_julian(j_noon - 0.5)
    }

    calc_times(result, @times, j_noon, lw, phi, dec, n, m, l)
  end

  defp calc_times(result, [], _, _, _, _, _, _, _), do: result
  defp calc_times(result, [htime|times], j_noon, lw, phi, dec, n, m, l) do
    j_set = get_set_j(Enum.at(htime, 0) * @rad, lw, phi, dec, n, m, l)
    j_rise = j_noon - (j_set - j_noon)

    new_result =
      result
      |> Dict.put_new(String.to_atom(Enum.at(htime, 1)), from_julian(j_rise))
      |> Dict.put_new(String.to_atom(Enum.at(htime, 2)), from_julian(j_set))
    calc_times(new_result, times, j_noon, lw, phi, dec, n, m, l)
  end
end
