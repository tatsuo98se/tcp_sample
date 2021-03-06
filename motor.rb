class Motor

    attr_reader(:pin_motor_in1, 
                :pin_motor_in2,
                :pin_motor_pwm,
                :pin_servo_pwm,
                :options)

    def initialize(pin_motor_in1, 
                   pin_motor_in2,
                   pin_motor_pwm,
                   pin_servo_pwm,
                   options)

        @pin_motor_in1 = pin_motor_in1
        @pin_motor_in2 = pin_motor_in2
        @pin_motor_pwm = pin_motor_pwm
        @pin_servo_pwm = pin_servo_pwm
        update_last_operation_date
    end

    def driveMotor(x, y)
        if((Time.now - @last_update) > 2.0) then
            sleep
            return;
        end
        if((x==0 && y==0) || ((Time.now - @last_update) > 0.5)) then
            set_motor_params(0.0, false, false)
            set_steering_params(0)
            return
        end

        p "drive motor #{x}, #{y}"
        pwm = [y.abs.to_f/100.0, 1].min
        if(y > 0) then
            set_motor_params(pwm, false, true)
        else
            set_motor_params(pwm, true, false)
        end

        steering = x/100.0
        if(x > 0) then
            steering = [steering, 1].min
        else
            steering = [steering, -1].max 
        end
        set_steering_params(steering)

    end

    def update_last_operation_date
        @last_update = Time.now
    end

    def set_motor_params(pwm, in1, in2)
        p "set_motor_params #{pwm} #{in1}, #{in2}"
    end

    # steer_in_percent: -1.0 〜 +1.0
    # -1.0: left
    #  0.0: center
    #  1.0: right
    # max steering degree is depend on implementation of subclass.
    def set_steering_params(steering_in_percent)
        p "set_steering_params #{steering_in_percent}"
    end

    def sleep
        p "sleep"
    end
end

class StubMotor < Motor
    def initialize(pin_motor_in1, 
                   pin_motor_in2,
                   pin_motor_pwm,
                   pin_servo_pwm,
                   options)

        super(pin_motor_in1, 
              pin_motor_in2,
              pin_motor_pwm,
              pin_servo_pwm,
              options)
        p "StubMotor.new #{pin_motor_in1}"
    end

    def set_motor_params(pwm, in1, in2)
        super(pwm, in1, in2)
    end

    def set_steering_params(steering_in_percent)
        super(steering_in_percent)
    end
end

require_relative 'real_motor'

def createMotor(pin_motor_in1, 
                pin_motor_in2,
                pin_motor_pwm,
                pin_servo_pwm,
                options)

    options = {
            mode: :production,
         }.merge(options)

    if(options[:mode] == :production) then
        return RealMotor.new(pin_motor_in1,
                             pin_motor_in2,
                             pin_motor_pwm,
                             pin_servo_pwm,
                             options)
    else
        return StubMotor.new(pin_motor_in1, 
                             pin_motor_in2,
                             pin_motor_pwm,
                             pin_servo_pwm,
                             options)
    end

end
