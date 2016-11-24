# buildkite-ding
:new::package: = :tram::bell:  
:white_check_mark::package: = :tram::bell::bell:  
:x::package: = :tram::bell::bell::bangbang::bell::bell::bell::bangbang::bangbang::bell::bell:

Ultra simple audible alerts for Buildkite build events, inspired by the ambiance of Melbourne

## Using
Initial build probably only works on MacOS (due to differences in playing audio files cross-platform).

Install the gem:
`gem install buildkite-ding`

Run command:
`buildkite-ding start`

At first run, you will be prompted to enter an API token, which will be saved to your home directory.

### Daemon
Currently uses the `daemon` Ruby framework to provide background services with start/stop/restart/run commands.
More options will be added in the future.