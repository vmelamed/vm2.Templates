// SPDX-License-Identifier: {{license}}

namespace vm2.MyPackage.Benchmarks;

//-:cnd:noEmit
#if SHORT_RUN
[ShortRunJob]
#else
[SimpleJob(RuntimeMoniker.HostProcess)]
#endif
//+:cnd:noEmit
public class EchoBenchmarks
{
    private string _value = "payload";

    [Benchmark]
    public string Echo_Value() => MyPackageApi.Echo(_value, "fallback");

    [Benchmark]
    public string Echo_Fallback() => MyPackageApi.Echo(null, "fallback");
}
