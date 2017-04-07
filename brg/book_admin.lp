<!DOCTYPE html> 
<% local book = _G.require("brg.book") %>
<html> 
	<head> 
		<title>创建账本</title> 
		<%=book.head %>
	</head> 
	<body>
		<div data-role="page">
			<%=book.header %>
			 <div data-role="content">
				<form action="book_crt.lp" method="POST" autocomplete="off">
					<ul data-role="listview" data-insert="true">
						<li data-role="fieldcontain">
							<label for="bookname">账本名称</label>
							<input type="text" name="bookname" id="bookname">
						</li>
            <li data-role="fieldcontain">
							<label for="passwd">管理密码</label>
							<input type="password" name="passwd" id="passwd">
						</li>
						<li data-role="fieldcontain">
							<input type="submit" value="确认" data-theme="a" >
						</li>
					</ul>
				</form>
			</div>
			<%=book.footer %>
		</div>
	</body>
</html>

