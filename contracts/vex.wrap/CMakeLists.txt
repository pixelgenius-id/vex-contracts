add_contract(vex.wrap vex.wrap ${CMAKE_CURRENT_SOURCE_DIR}/src/vex.wrap.cpp)

target_include_directories(vex.wrap
   PUBLIC
   ${CMAKE_CURRENT_SOURCE_DIR}/include)

set_target_properties(vex.wrap
   PROPERTIES
   RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")

configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/ricardian/vex.wrap.contracts.md.in ${CMAKE_CURRENT_BINARY_DIR}/ricardian/vex.wrap.contracts.md @ONLY )

target_compile_options( vex.wrap PUBLIC -R${CMAKE_CURRENT_SOURCE_DIR}/ricardian -R${CMAKE_CURRENT_BINARY_DIR}/ricardian )
