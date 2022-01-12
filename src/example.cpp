#include <hannessteffenhagen/example.hpp>
#include <fmt/format.h>

std::string hannessteffenhagen::greeting(std::string_view name) {
  return fmt::format("Hello, {}!", name);
}

#if example_CONFIG_TEST

#include <doctest/doctest.h>

using namespace hannessteffenhagen;

TEST_CASE("saying hello") {
  SUBCASE("to me") {
    CHECK(greeting("Hannes") == "Hello, Hannes!");
  }

  SUBCASE("to the world") {
    CHECK(greeting("World") == "Hello, World!");
  }
}


#endif
