package version

import (
	"fmt"
	"runtime"

	apimachineryversion "k8s.io/apimachinery/pkg/version"
)

// TODO: Mock it for now. We may not need all the info.
func Get() apimachineryversion.Info {
	// These variables typically come from -ldflags settings and in
	// their absence fallback to the settings in ./base.go
	return apimachineryversion.Info{
		Major:        gitMajor,
		Minor:        gitMinor,
		GitVersion:   gitVersion,
		GitCommit:    gitCommit,
		GitTreeState: gitTreeState,
		BuildDate:    buildDate,
		GoVersion:    runtime.Version(),
		Compiler:     runtime.Compiler,
		Platform:     fmt.Sprintf("%s/%s", runtime.GOOS, runtime.GOARCH),
	}
}
