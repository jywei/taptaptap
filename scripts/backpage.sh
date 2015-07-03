#!/bin/bash
        for i in {0..29};
        do
                bundle exec rails runner "BackpageProcess.new.process(true, 12, $i)" -e production >> log/bk_process$i.log 2>&1 &
        done
