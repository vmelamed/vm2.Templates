// SPDX-License-Identifier: {{license}}

namespace vm2.MyPackage.Tests;

public class MyPackageApiTests
{
    [Fact]
    public void Echo_returns_value_when_present()
    {
        var result = MyPackageApi.Echo("hi", "fallback");
        result.Should().Be("hi");
    }

    [Fact]
    public void Echo_returns_fallback_when_null()
    {
        var result = MyPackageApi.Echo(null, "fallback");
        result.Should().Be("fallback");
    }
}
