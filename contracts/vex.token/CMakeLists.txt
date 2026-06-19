add_contract(vex.token vex.token ${CMAKE_CURRENT_SOURCE_DIR}/src/vex.token.cpp)

target_include_directories(vex.token
   PUBLIC
   ${CMAKE_CURRENT_SOURCE_DIR}/include)

set_target_properties(vex.token
   PROPERTIES
   RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")

configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/ricardian/vex.token.contracts.md.in ${CMAKE_CURRENT_BINARY_DIR}/ricardian/vex.token.contracts.md @ONLY )

target_compile_options( vex.token PUBLIC -R${CMAKE_CURRENT_SOURCE_DIR}/ricardian -R${CMAKE_CURRENT_BINARY_DIR}/ricardian )
