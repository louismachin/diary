require 'socket'

$diary_verbs = {}

diary_port_path = File.join(__dir__, '..', '.port')
DIARY_PORT = File.read(diary_port_path) || 1734

require_relative './context'
require_relative './blocks'
require_relative './verbs'
require_relative './socket'