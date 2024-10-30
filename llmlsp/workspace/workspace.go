package workspace

type Workspace struct {
	Files    *Files
	RootPath string
}

func New() *Workspace {
	return &Workspace{Files: NewFiles()}
}
