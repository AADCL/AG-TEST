#include <cassert>
#include <cmath>

#include "ground_air_mapping/voxel_accumulator.hpp"

int main() {
    ground_air_mapping::VoxelAccumulator accumulator(0.10, 2);
    assert(accumulator.add(0.01, 0.01, 0.01));
    assert(accumulator.add(0.09, 0.01, 0.01));
    assert(accumulator.size() == 1);

    auto points = accumulator.centroids();
    assert(points.size() == 1);
    assert(std::abs(points[0].x - 0.05) < 1e-9);

    assert(accumulator.add(0.11, 0.01, 0.01));
    assert(accumulator.size() == 2);
    assert(!accumulator.add(NAN, 0.0, 0.0));
    assert(!accumulator.add(0.21, 0.01, 0.01));
    assert(accumulator.capacityExceeded());

    accumulator.clear();
    assert(accumulator.size() == 0);
    assert(!accumulator.capacityExceeded());
    return 0;
}
