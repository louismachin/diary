def define(verb, &block)
    raise "A block is required to define a verb" unless block_given?
    $diary_verbs[verb.to_s.upcase] = block
end