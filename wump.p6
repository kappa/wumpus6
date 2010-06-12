#! /usr/local/bin/pugs

constant $N_ROOMS = 25;
constant @ROOMS = 0 .. $N_ROOMS - 1;

my @cave_mat;

my (Int $player, Int $wumpus, @cave);

# ========================================

create_cave();

loop {
    # 0. check
    if $player == $wumpus {
        die "You are eaten";
    }

    # 1. report
    say "You are in $player (wumpus sleeps in $wumpus)";
    say "You can go to &links($player)";

    # 2. read
    say "Move?";
    my $cmd = =<>;

    # 3. act
    $player = $cmd if $cmd == any(links($player));
}

# ========================================


sub create_cave {
    @cave_mat = map { [ 0 xx $N_ROOMS ] }, @ROOMS;

    my Int $next = rand($N_ROOMS);
    for @ROOMS -> $room {
        my $n_links = links($room).elems;

        while $n_links < 3 {
            next if linked($room, $next);
            next if links($next).elems >= 3;

            dig_link($room, $next)
                and ++$n_links;

            NEXT { $next = ($next + 1) % $N_ROOMS; }
        }

        say ~links($room);
    }

    say join "\n", map { ~@($_) }, @cave_mat;

    die unless coupled();

    $wumpus = int rand($N_ROOMS + 1);
    $player = int rand($N_ROOMS + 1);
}

sub linked($from, $to) {
    return @cave_mat[$from][$to];
}

sub dig_link($from, $to) {
    @cave_mat[$from][$to] = @cave_mat[$to][$from] = 1;
}

sub links($from) {
    return grep { @cave_mat[$from][$_] }, @ROOMS;
}

sub coupled {
    my @queue = (0,);
    my @connected = 0 xx $N_ROOMS;
    @connected[@queue[0]] = 1;

    while defined (my $top = @queue.shift) {
        say "top = $top, queue = @queue[]";

        push @queue, grep { !@connected[$_] }, links($top);

        $_ = 1 for @connected[@queue];
    }

    return [&&] @connected;
}
