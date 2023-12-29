### 创建超链接
### 使用powershell执行
# https://winaero.com/create-symbolic-link-windows-10-powershell/
New-Item -ItemType Junction -Path "/Users/ted/workspace/github/guolb.github.io/public" -Target "/Users/ted/workspace/github/guolb.github.io.deploy"
