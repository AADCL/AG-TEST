# CMake generated Testfile for 
# Source directory: /home/bitcq/catkin_ws/src/ground_air_mapping
# Build directory: /home/bitcq/catkin_ws/build/ground_air_mapping
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(_ctest_ground_air_mapping_nosetests_tests.test_mapping_package_contract.py "/home/bitcq/catkin_ws/build/catkin_generated/env_cached.sh" "/usr/bin/python3" "/opt/ros/noetic/share/catkin/cmake/test/run_tests.py" "/home/bitcq/catkin_ws/build/test_results/ground_air_mapping/nosetests-tests.test_mapping_package_contract.py.xml" "--return-code" "\"/home/bitcq/.local/lib/python3.8/site-packages/cmake/data/bin/cmake\" -E make_directory /home/bitcq/catkin_ws/build/test_results/ground_air_mapping" "/usr/bin/nosetests3 -P --process-timeout=60 /home/bitcq/catkin_ws/src/ground_air_mapping/tests/test_mapping_package_contract.py --with-xunit --xunit-file=/home/bitcq/catkin_ws/build/test_results/ground_air_mapping/nosetests-tests.test_mapping_package_contract.py.xml")
set_tests_properties(_ctest_ground_air_mapping_nosetests_tests.test_mapping_package_contract.py PROPERTIES  _BACKTRACE_TRIPLES "/opt/ros/noetic/share/catkin/cmake/test/tests.cmake;160;add_test;/opt/ros/noetic/share/catkin/cmake/test/nosetests.cmake;83;catkin_run_tests_target;/home/bitcq/catkin_ws/src/ground_air_mapping/CMakeLists.txt;36;catkin_add_nosetests;/home/bitcq/catkin_ws/src/ground_air_mapping/CMakeLists.txt;0;")
add_test(ground_air_mapping_voxel_accumulator "/home/bitcq/catkin_ws/devel/lib/ground_air_mapping/test_voxel_accumulator")
set_tests_properties(ground_air_mapping_voxel_accumulator PROPERTIES  _BACKTRACE_TRIPLES "/home/bitcq/catkin_ws/src/ground_air_mapping/CMakeLists.txt;39;add_test;/home/bitcq/catkin_ws/src/ground_air_mapping/CMakeLists.txt;0;")
