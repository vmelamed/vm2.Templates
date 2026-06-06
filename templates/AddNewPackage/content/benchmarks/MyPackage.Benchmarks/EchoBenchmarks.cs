// SPDX-License-Identifier: MIT
// Copyright (c) 2025-2026 Val Melamed

namespace vm2.Benchmarks.MyPackage;

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
