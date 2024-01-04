<<~PLAYERS
      {b=>2, c=>5, a=>1, d=>1}
    PLAYERS
    pp = players.to_a.sort{|x, y| x[1]<=>y[1]}
    <<~PP
      [[a, 1], [d, 1], [b, 2], [c, 5]]
    PP
    hp = {}
    pp.each{|x| hp[x[1]] ? hp[x[1]]<<x[0] : hp[x[1]] = [x[0]]}
    <<~HP
      {1: [a,d], 2: [b], 5: [c]}
    HP
    puts("#>>> HP: #{hp.to_s}")
    xp = []
    hp.each{|k,v| xp << v.shuffle.product([k])}
    <<~XP
      [[[d,1], [a,1]], [[b, 2]], [[c,5]]]
    XP
    puts("#>>> XP: #{xp.to_s}")
    xp = xp.inject{|x,y|x+y}
    <<~XP
      [[d,1], [a,1], [b, 2], [c,5]]
    XP
    puts("#>>> after inject XP: #{xp.to_s}")
    pp = xp.zip(xp.reverse)
    <<~PP
      [[d,1], [a,1], [b, 2], [c,5]].zip([[c,5], [b, 2], [a,1], [d,1]])
      [
        [[d,1], [c,5]],
        [[a,1], [b,2]],
        [[b,2], [a,1]],
        [[c,5], [d,1]]
      ]
    PP
    puts("#>>>> pp: #{pp.to_s}")