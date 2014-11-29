class Packer
  class Box
    attr_reader :center, :dimensions, :vertices, :edge_ordered_pairs

    def initialize(coordinates, dimensions)
      @center = coordinates
      @dimensions = dimensions
    end

    def edge_ordered_pairs
      @edge_ordered_pairs ||=
      {
        x: [ center[:x] - dimensions[:width]/2.0,  center[:x] + dimensions[:width]/2.0 ],
        y: [ center[:y] - dimensions[:height]/2.0, center[:y] + dimensions[:height]/2.0 ],
        z: [ center[:z] - dimensions[:length]/2.0, center[:x] + dimensions[:length]/2.0 ]
      }
    end

    def vertices
      @vertices ||= [
        { x: edge_ordered_pairs[:x][0], y: edge_ordered_pairs[:y][0], z: edge_ordered_pairs[:z][0] },
        { x: edge_ordered_pairs[:x][1], y: edge_ordered_pairs[:y][0], z: edge_ordered_pairs[:z][0] },
        { x: edge_ordered_pairs[:x][0], y: edge_ordered_pairs[:y][1], z: edge_ordered_pairs[:z][0] },
        { x: edge_ordered_pairs[:x][0], y: edge_ordered_pairs[:y][0], z: edge_ordered_pairs[:z][1] },
        { x: edge_ordered_pairs[:x][1], y: edge_ordered_pairs[:y][1], z: edge_ordered_pairs[:z][0] },
        { x: edge_ordered_pairs[:x][1], y: edge_ordered_pairs[:y][0], z: edge_ordered_pairs[:z][1] },
        { x: edge_ordered_pairs[:x][0], y: edge_ordered_pairs[:y][1], z: edge_ordered_pairs[:z][1] },
        { x: edge_ordered_pairs[:x][1], y: edge_ordered_pairs[:y][1], z: edge_ordered_pairs[:z][1] },
      ]
    end

    def move(new_center)
      @center = new_center
      reset_edges_and_vertices
      self
    end

    private

    # reset memoized values
    def reset_edges_and_vertices
      @edge_ordered_pairs, @vertices = nil, nil
    end
  end

  def self.intersecting?(box1, box2)
    box1.vertices.each do |vertex|
      # if vertex x,y,z values are all within min/max of x,y,z on edge ordered pairs,
      # then box1 has a vertex inside box2 and is intersecting
      return true if [:x,:y,:z].all? do |key|
        vertex[key] >= box2.edge_ordered_pairs[key][0] && vertex[key] <= box2.edge_ordered_pairs[key][1]
      end
    end

    false
  end
end
