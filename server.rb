require 'socket'
require 'timers'
require_relative 'motor'

xdirection = 0
ydirection = 0

#motor
motor = createMotor(4, 17, 13, 12, {mode: :production})

#Timer
timers = Timers::Group.new
timer = timers.now_and_every(0.1) { motor.driveMotor(xdirection, ydirection) }
Thread.start{loop{timers.wait}}

#20000番のポートを解放
s = TCPServer.open(20000)

i = 0
while true
  p "waiting connection... #{i}"
  i = i + 1
  
  thread = Thread.start(s.accept) do |socket|
    id = socket.peeraddr
    p "#{id} connection success."

    while buf = socket.gets
      x, y =  buf.split(",")
      p buf
      xdirection = x.to_i
      ydirection = y.to_i
      motor.update_last_operation_date
    end
    socket.close
    p "#{id} connection terminate."
  end  
end
