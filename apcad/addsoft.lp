<!DOCTYPE html>
<% local apcad = _G.require("apcad.apcad") %>
<html>
	<head>
		<title>添加软件</title>
		<%=apcad.head %>
	</head>
	<body>
		<div data-role="page">
			<%=apcad.header() %>
			<div data-role="content">
				<form action="addsoft.lp" method="post">
					<ul data-role="listview" data-insert="true">
						<li data-role="fieldcontain">
							<label for="softname">软件名称</label>
							<input type = "text" name = "softname" id="softname">
						</li>
						<li data-role="fieldcontain">
							<label for="price">软件单月价格</label>
							<input type = "number" name = "price" id="price">
						</li>
						<li data-role="fieldcontain">
							<label for="owner">软件作者</label>
							<input type = "text" name = "owner" id="owner">
						</li>
						<li data-role="fieldcontain">
							<input type = "submit" value = "确认" data-theme="b">
						</li>
					</ul>
				</form>
				<%=apcad.footer %>
			</div>
			<% 
			if softname and owner and price then 
				ct = _G.socket.connect(apcad.addr,apcad.port)
				local str="add_soft\r\n" ..softname .. "\r\n" .. owner .. "\r\n" .. price .. "\r\n"
				apcad.send_str(ct,str)
				local answer = apcad.recv_str(ct)
				ct:close()
				local flag = answer ~= "add_soft\r\n-1\r\n" 
			end 
			%>
	</body>
</html>
