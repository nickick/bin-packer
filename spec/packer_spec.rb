require 'spec_helper'
require_relative '../packer'

describe Packer do
  it "should initialize without error" do
    expect { described_class.new }.to_not raise_error
  end

  describe Packer::Box do
    subject { described_class.new(coordinates, dimensions) }

    context "with an origin and dimensions" do
      let(:coordinates) { { x: 0, y: 0, z: 0 } }
      let(:dimensions)  { { width: 2, height: 4, length: 6 } }

      describe "initialization" do
        it "should assign coordinates to a center" do
          expect(subject.center).to eq coordinates
        end

        it "should assign dimensions" do
          expect(subject.dimensions).to eq dimensions
        end
      end

      describe "#edge_ordered_pairs" do
        it "should retun ordered pairs for each axis" do
          expect(subject.edge_ordered_pairs).to eq({
            x: [-1.0, 1.0],
            y: [-2.0, 2.0],
            z: [-3.0, 3.0]
          })
        end
      end

      describe "#vertices" do
        it "should return vertices" do
          expect(subject.vertices).to contain_exactly(
            { x: 1.0 , y: 2.0 , z: 3.0  },
            { x: -1.0, y: 2.0 , z: 3.0  },
            { x: 1.0 , y: -2.0, z: 3.0  },
            { x: 1.0 , y: 2.0 , z: -3.0 },
            { x: -1.0, y: -2.0, z: 3.0  },
            { x: -1.0, y: 2.0 , z: -3.0 },
            { x: 1.0 , y: -2.0, z: -3.0 },
            { x: -1.0, y: -2.0, z: -3.0 }
          )
        end
      end

      describe "#move" do
        let(:new_center) { { x: 5, y: 5, z: 5} }

        it "should move the box's center to the new coordinates" do
          expect(subject.move(new_center).center).to eq(new_center)
        end

        it "should update the box's edge ordered pairs to center around the new coordinats" do
          expect(subject.move(new_center).edge_ordered_pairs).to eq({
            x: [4,6],
            y: [3,7],
            z: [2,8]
          })
        end

        it "should update the box's vertices to center around the new coordinates" do
          expect(subject.move(new_center).vertices).to contain_exactly(
            { x: 6.0, y: 7.0, z: 8.0 },
            { x: 4.0, y: 7.0, z: 8.0 },
            { x: 6.0, y: 7.0, z: 2.0 },
            { x: 4.0, y: 3.0, z: 8.0 },
            { x: 6.0, y: 3.0, z: 2.0 },
            { x: 4.0, y: 7.0, z: 2.0 },
            { x: 6.0, y: 3.0, z: 8.0 },
            { x: 4.0, y: 3.0, z: 2.0 }
          )
        end
      end
    end
  end

  describe "#intersecting?" do
    context "with two clearly intersecting boxes" do
      let(:box1) { Packer::Box.new({ x: 0, y: 0, z: 0 }, { width: 2, height: 4, length: 6 }) }
      let(:box2) { Packer::Box.new({ x: 1, y: 1, z: 1 }, { width: 2, height: 4, length: 6 }) }

      it "should return true" do
        expect(Packer.intersecting?(box1, box2)).to eq true
      end
    end

    context "with two boxes only intersecting at one vertex" do
      let(:box1) { Packer::Box.new({ x: 0, y: 0, z: 0 }, { width: 2, height: 4, length: 6 }) }
      let(:box2) { Packer::Box.new({ x: 2, y: 4, z: 6 }, { width: 2, height: 4, length: 6 }) }

      it "should return true" do
        expect(box1.vertices).to include({ x: 1.0 , y: 2.0 , z: 3.0  })
        expect(box2.vertices).to include({ x: 1.0 , y: 2.0 , z: 3.0  })
        expect(Packer.intersecting?(box1, box2)).to eq true
      end
    end

    context "with two non-intersecting boxes" do
      let(:box1) { Packer::Box.new({ x: 0, y: 0, z: 0 },   { width: 2, height: 4, length: 6 }) }
      let(:box2) { Packer::Box.new({ x: 2, y: 4, z: 6.1 }, { width: 2, height: 4, length: 6 }) }

      it "should return false" do
        expect(Packer.intersecting?(box1, box2)).to eq false
      end
    end
  end
end
