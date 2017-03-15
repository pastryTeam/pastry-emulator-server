# Pastry Emulator Server
1.模拟桥是什么   
模拟桥是在开发混合app的时候，方便前期在浏览器中调试接口使用。    
模拟桥本质上担任的是  原生端（ios）角色；起到的作用是加、解密，转发、接收请求。     
2.使用方法     
在项目资源库**pastry-emulator-server**文件夹中    
- 执行npm install 命令，安装依赖资源     
- pastry-emulator-server/bin文件夹如下有四个文件：    
     emulator-server文件    
     emulator-server.bat文件     
     win-run-local.bat文件    
     win-run-server.bat文件   
     第一个文件是macOS下启动服务命令，根据需要后面添加local/server命令行参数；  
     后两个文件是windows系统下的启动服务文件    
     wind-run-local 是启动本地服务，接口返回数据在pastry-emulator-server\wwwroot\mockdata下伪造；这个服务是在开发前期，前置、后台还未开发的时候供前端自己调试接口操作使用的；    
     win-run-server连接的是真实的前置服务器，需要在pastry-emulator-server\data\config.js里面修改前置服务器ip地址、端口、名称，再运行。这个服务是在前置开发完成，双方进行联调阶段使用的，避免了真机调试的麻烦。     
- 启动相应服务后，在另一个命令行下启动项目      
- 在浏览器控制台查看日志反馈，进行调试         
3.提示     
模拟桥是在浏览器环境下模拟原生端，方便接口调试的。      
  


