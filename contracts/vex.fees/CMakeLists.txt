add_contract(vex.fees vex.fees ${CMAKE_CURRENT_SOURCE_DIR}/src/vex.fees.cpp)

target_include_directories(vex.fees PUBLIC
   ${CMAKE_CURRENT_SOURCE_DIR}/include
   ${CMAKE_CURRENT_SOURCE_DIR}/../vexcore/include)

set_target_properties(vex.fees
   PROPERTIES
   RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")

target_compile_options( vex.fees PUBLIC )
