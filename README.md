[![Build Status](https://travis-ci.org/aussiegeek/astro.svg?branch=master)](https://travis-ci.org/aussiegeek/astro)

# Astro

Calculate sunrise & sunset for given location. 

```

Astro.get_times(-39.8, 144.96)

# Result

%{dawn: #<DateTime(2016-10-02T19:25:36Z Etc/UTC)>,
  dusk: #<DateTime(2016-10-03T08:55:13Z Etc/UTC)>,
  golden_hour: #<DateTime(2016-10-03T07:52:24Z Etc/UTC)>,
  golden_hour_end: #<DateTime(2016-10-02T20:28:25Z Etc/UTC)>,
  nadir: #<DateTime(2016-10-02T14:10:25Z Etc/UTC)>,
  nautical_dawn: #<DateTime(2016-10-02T18:53:33Z Etc/UTC)>,
  nautical_dusk: #<DateTime(2016-10-03T09:27:16Z Etc/UTC)>,
  night: #<DateTime(2016-10-03T10:00:14Z Etc/UTC)>,
  night_end: #<DateTime(2016-10-02T18:20:35Z Etc/UTC)>,
  solar_noon: #<DateTime(2016-10-03T02:10:25Z Etc/UTC)>,
  sunrise: #<DateTime(2016-10-02T19:52:47Z Etc/UTC)>,
  sunrise_end: #<DateTime(2016-10-02T19:55:34Z Etc/UTC)>,
  sunset: #<DateTime(2016-10-03T08:28:02Z Etc/UTC)>,
  sunset_start: #<DateTime(2016-10-03T08:25:15Z Etc/UTC)>}
```

## Installation

  1. Add `astro` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:astro, "~> 0.1.0"}]
    end
    ```

  2. Ensure `astro` is started before your application:

    ```elixir
    def application do
      [applications: [:astro]]
    end
    ```

