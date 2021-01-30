# frozen_string_literal: true

# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
#
THREAD_COUNT = ENV.fetch('RAILS_MAX_THREADS', 5)
threads THREAD_COUNT, THREAD_COUNT

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
#
port ENV.fetch('PORT', 3000)

# Allow puma to be restarted by `rails restart` command.
#
plugin :tmp_restart

# Experimental performance features of Puma 5.
#
wait_for_less_busy_worker 0.001
nakayoshi_fork
