// SPDX-License-Identifier: {{license}}

using BenchmarkDotNet.Attributes;
using vm2.MyPackage;

namespace vm2.MyPackage.Benchmarks;

[MemoryDiagnoser]
[DisassemblyDiagnoser(maxDepth: 1)]
public class EchoBenchmarks
{
    private string _value = "payload";

    [Benchmark]
    public string Echo_Value() => MyPackageApi.Echo(_value, "fallback");

    [Benchmark]
    public string Echo_Fallback() => MyPackageApi.Echo(null, "fallback");
}
