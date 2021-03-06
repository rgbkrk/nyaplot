module Nyaplot
  module Sheet
    # Root class for glyphs
    class Context
      include Nyaplot::Base
      type :context2d
      required_args :glyphs
      optional_args :width, :height

      def add_glyph(*glyph)
        glyphs([]) if glyphs.nil?

        glyph.each{|g|
          glyph.push(g.child) if g.respond_to? :child
        }

        glyphs.concat(glyph)
        add_dependency(*glyph)

        class << glyphs
          def to_json(*args)
            self.map{|obj| obj.uuid}.to_json
          end
        end
      end

      def range(method_name)
        glyphs.reduce([Float::INFINITY, -Float::INFINITY]) do |memo, g|
          if (r = g.send(method_name)).length != 2 || r.any? {|val| !(val.is_a?(Numeric))}
            memo.delete(Float::INFINITY)
            memo.delete(-Float::INFINITY)
            memo.concat(r.to_a).uniq
          else
            min, max = r
            memo[0] = [min, memo[0]].min
            memo[1] = [max, memo[1]].max
            memo
          end
        end
      end

      def xscale(range)
        r = range(:range_x)
        s = Scale.new(domain: r, range: range)
        s.type(r.all? {|v| v.is_a? Numeric} ? :linear : :ordinal)
        s
      end

      def yscale(range)
        r = range(:range_y)
        s = Scale.new(domain: r, range: range)
        s.type(r.all? {|v| v.is_a? Numeric} ? :linear : :ordinal)
        s
      end

      def position(pos)
        @dependency.each do |g|
          g.position(pos)
        end
      end

      alias :add :add_glyph
    end

    class Axis
      include Nyaplot::Base
      type :axis2d
      required_args :xscale, :yscale, :width, :height
      optional_args :margin, :stroke_color, :stroke_width, :grid

      def before_to_json
        raise "width and height should be specified" if [width, height].any? {|a| a.nil?}
      end
    end

    class Background
      include Nyaplot::Base
      type :background2d
      required_args :width, :height
      optional_args :bg_color, :stroke_width, :stroke_color
    end
  end
end
