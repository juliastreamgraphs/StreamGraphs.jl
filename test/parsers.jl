# Parser tests
@test parse_line_auv("1.0 a b",1.0)==(0.5,1.5,"a","b")
@test parse_line_auv("0.0 b a",0.5)==(-0.25,0.25,"b","a")
@test parse_line_auv("6.0 node1 node2",2.0)==(5.0,7.0,"node1","node2")
@test parse_line_auv("0.0 b a")==(-0.5,0.5,"b","a")
@test parse_line_auv("1.0 a b")==parse_line_auv("1.0 a b",1.0)
@test parse_line_abuv("0.0 1.0 a b")==(0.0,1.0,"a","b")
@test parse_line_abuv("-0.5 0.5 c b")==(-0.5,0.5,"c","b")
@test parse_line_abuv("0.0 1.0 a b",2.0)==(0.0,1.0,"a","b")
@test parse_line("1.0 a b","auv")==(0.5,1.5,"a","b")
@test parse_line("1.0 a b","auv",1.0)==(0.5,1.5,"a","b")
@test parse_line("1.0 a b","auv",2.0)==(0.0,2.0,"a","b")
@test parse_line("0.0 1.0 a b","abuv")==(0.0,1.0,"a","b")
@test parse_line("0.0 1.0 a b","abuv",2.0)==(0.0,1.0,"a","b")

events=parse_to_events("./test_data/auv_test_1.txt","auv",0.05)
@test length(events)==8
@test events[1]==LinkEvent(-0.025,true,("a","b"))
@test string(events[1])=="-0.025 + a b"
@test events[2]==LinkEvent(0.025,false,("a","b"))
@test string(events[2])=="0.025 - a b"
@test events[3]==LinkEvent(0.475,true,("a","c"))
@test string(events[3])=="0.475 + a c"
@test events[4]==LinkEvent(0.525,false,("a","c"))
@test string(events[4])=="0.525 - a c"
@test events[5]==LinkEvent(0.575,true,("a","c"))
@test events[6]==LinkEvent(0.625,false,("a","c"))
@test events[7]==LinkEvent(0.975,true,("a","b"))
@test events[8]==LinkEvent(1.025,false,("a","b"))

events=parse_to_events("./test_data/auv_test_1.txt","auv",0.1)
@test length(events)==6
@test events[1]==LinkEvent(-0.05,true,("a","b"))
@test events[2]==LinkEvent(0.05,false,("a","b"))
@test events[3]==LinkEvent(0.45,true,("a","c"))
@test events[4]==LinkEvent(0.65,false,("a","c"))
@test events[5]==LinkEvent(0.95,true,("a","b"))
@test events[6]==LinkEvent(1.05,false,("a","b"))

events=parse_to_events("./test_data/auv_test_1.txt","auv",1.0)
@test length(events)==4
@test events[1]==LinkEvent(-0.5,true,("a","b"))
@test events[2]==LinkEvent(0.0,true,("a","c"))
@test events[3]==LinkEvent(1.1,false,("a","c"))
@test events[4]==LinkEvent(1.5,false,("a","b"))