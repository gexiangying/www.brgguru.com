<!DOCTYPE html> 
<% local book = _G.require("brg.book") %>
<html> 
	<head> 
		<title>账本管理</title>
		<%=book.head %>
	</head>	
	<% if bookname and passwd and item and itemname then %>
	<%
	db = book.load_book(bookname)
	if book.auth_input(db,bookname,passwd) then
	  db.items = db.items or {}
		db.persons = db.persons or {}
		if item == "item" then
		db.items[itemname] = not db.items[itemname] or nil
		elseif item == "person" then
		db.persons[itemname] = not db.persons[itemname] or nil
		end
		book.save_book(bookname,db)
	end
	%>
	<% end %>
	<body>
		<div data-role="page" >
			<%=book.header %>
			<div data-role="content">
				<form action="book_edit.lp" method="POST" autocomplete="off">
					<ul data-role="listview" data-insert="true">
						<% if bookname and passwd then %>
						<input type="hidden" name="bookname" value="<%=bookname %>" />
						<input type="hidden" name="passwd" value="<%=passwd %>" />
						<% else %>
						<li data-role="fieldcontain">
							<label for="bookname">账本名称</label>
							<input type="text" name="bookname" id="bookname">
						</li>
						<li data-role="fieldcontain">
							<label for="passwd">管理密码</label>
							<input type="password" name="passwd" id="passwd">
						</li>
						<% end %>
						<li data-role="fieldcontain">
							<select name="item" id="item" data-native-menu="true">
									<option value="item">项目</option>
									<option value="person">人员</option>
								</select>
            </li>
						<li data-role="fieldcontain">
							<label for="itemname">名称</label>
							<input type="text" name="itemname" id="itemname">
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
