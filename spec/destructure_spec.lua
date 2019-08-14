return describe("destructure", function()
  it("should unpack array", function()
    local input = {
      1,
      2,
      3
    }
    local a, b, c
    do
      local _obj_0 = {
        1,
        2,
        3
      }
      a, b, c = _obj_0[1], _obj_0[2], _obj_0[3]
    end
    local d, e, f
    d, e, f = input[1], input[2], input[3]
    assert.same(a, 1)
    assert.same(b, 2)
    assert.same(c, 3)
    assert.same(d, 1)
    assert.same(e, 2)
    return assert.same(f, 3)
  end)
  return it("should destructure", function()
    local futurists = {
      sculptor = "Umberto Boccioni",
      painter = "Vladimir Burliuk",
      poet = {
        name = "F.T. Marinetti",
        address = {
          "Via Roma 42R",
          "Bellagio, Italy 22021"
        }
      }
    }
    local name, street, city
    name, street, city = futurists.poet.name, futurists.poet.address[1], futurists.poet.address[2]
    assert.same(name, "F.T. Marinetti")
    assert.same(street, "Via Roma 42R")
    return assert.same(city, "Bellagio, Italy 22021")
  end)
end)
