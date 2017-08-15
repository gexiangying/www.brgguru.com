<!DOCTYPE html>
<% local apcad = _G.require("apcad.apcad") %>
<html>
<head>
<title>Welcome to apcad!</title>
<%=apcad.head %>
</head>
<body>
 <div data-role="page">
	 <%=apcad.header() %>
	 <div data-role="content">
		 <%
			 local url = _G.require("lpp.url")
			 local sessionid = apcad.sessionid()
			 sessionid = url.escape(sessionid) 
			 %>
		 <form action="login.lp?sessionid=<%=sessionid %>" method="post">
			<ul data-role="listview" data-insert="true">
				<li data-role="fieldcontain">
					<label for="user">用户名称</label>
						<input type = "text" name = "user" id="user">
				</li>
				<li data-role="fieldcontain">
					<label for="psw">密码</label>
					<input type="password" name="psw" id = "psw">
				</li>
				<li data-role="fieldcontain">
					<input type = "submit" value = "确认" data-theme="b">
				</li>
		</form>

	 </div>
	 <%=apcad.footer %>
 </div>
</body>
</html>
