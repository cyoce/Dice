Context = Struct.new('Context', :explode)




class Roll
    def initialize type
        @n = type
    end

    def + (other)
        Add.new(self, other)
    end
    
    def - (other)
        Add.new(self, -other)
    end
    
    def * (other)
        Mul.new(self, other)
    end
    
    def / (other)
        Wild.new(self, other)
    end
    

    def roll(*explode)
        explode = [0] if explode.empty?
        out = 0
        loop do  
            out += v = Random.rand(@n) + 1
            break unless explode.include?(v % @n)
        end
        out
    end
    
    def inspect
        to_s
    end
    
    def to_s
        "d#@n"
    end
    
    def test(n=4, *ex, &block)
        run_test(n, false, *ex, &block)
    end
    
    def ytest(n=4, *ex, &block)
        run_test(n, true, *ex, &block)
    end
    
    def run_test(n, y, *ex, &block)
        ex = [0] if ex.empty?
        n = 10 ** n
        sum = 0
        n.times do 
            v = y ? instance_exec(@r=roll(*ex), &block) : block[self]
            v = 1 if v == true
            v = 0 if v == false
            v = v[*ex] if v.is_a?(Roll)
            sum += v
        end
        n = n.to_f if n.is_a?(Integer)
        sum / n
    end
    
    
    def tn(t=4, ex=[0])
        [(roll(ex)-t+4) / 4,0].max
    end
    
    def +@; roll; end
    def r(*a); roll(*a); end
    def w; self / Roll[6]; end
    def [](*a); roll(*a); end
    class << self
        def [](n)
            @@cache ||= {}
            @@cache[n] ||= new(n)
        end
    end
end

def d(n=6); Roll[n]; end
D4 = d 4
D6 = d 6
D8 = d 8
D10 = d 10
D12 = d 12
def d4; D4; end
def d6; D6; end
def d8; D8; end
def d10; D10; end
def d12; D12; end

class Add < Roll
    def initialize a, b
        @a = a
        @b = b
    end
    
    def roll(*explode)
        explode = [0] if explode.empty?
        @a.roll(explode) + @b.roll(explode)
    end
    
    def to_s
        "#@a + #@b"
    end
end

class Mul < Roll
    def initialize *a
       @a, @b = a
    end
    
    def roll(*ex)
        ex = [0] if ex.empty?
        @a.roll(ex) + @b.roll(ex)
    end
    
    def to_s
        "#@a * #@b"
    end
end

class Wild < Roll
    def initialize *a; @a,@b=a; end
    
    def roll(*ex)
        ex = [0] if ex.empty?
       [@a.roll(ex), @b.roll(ex)].max
    end
    
    def to_s
        "(#@a | #@b)"
    end
end
class Numeric
    def roll(*); self; end
    def d(n); Array.new(self){Roll[n]}.inject(:+); end
    @@cache = {}
    def tn(t=4)
        [(self-t+4) / 4,0].max
    end
    def d4; @@cache[[self, 4]] ||= d 4; end
    def d6; @@cache[[self, 6]] ||= d 6; end
    def d8; @@cache[[self, 8]] ||= d 8; end
    def d10; @@cache[[self, 10]] ||= d 10; end
    def d12; @@cache[[self, 12]] ||= d 12; end
    
end