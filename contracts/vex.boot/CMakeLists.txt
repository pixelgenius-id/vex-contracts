add_contract(vex.boot vex.boot ${CMAKE_CURRENT_SOURCE_DIR}/src/vex.boot.cpp)

target_include_directories(vex.boot
   PUBLIC
   ${CMAKE_CURRENT_SOURCE_DIR}/include)

set_target_properties(vex.boot
   PROPERTIES
   RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")

configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/ricardian/vex.boot.contracts.md.in ${CMAKE_CURRENT_BINARY_DIR}/ricardian/vex.boot.contracts.md @ONLY )

target_compile_options( vex.boot PUBLIC -R${CMAKE_CURRENT_SOURCE_DIR}/ricardian -R${CMAKE_CURRENT_BINARY_DIR}/ricardian )
