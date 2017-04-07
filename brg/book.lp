<!DOCTYPE html> 
<% local book = _G.require("brg.book") %>
<html> 
	<head> 
		<title>记账</title> 
		<%=book.head %>
	</head> 
	<body>
		<div data-role="page">
			<%=book.header %>
			<div data-role="content">
				<form action="book.lp" method="POST" autocomplete="off">
					<ul data-role="listview" data-insert="true">
						<% if bookname and passwd then %>
						<input type="hidden" name="bookname" value="<%=bookname %>" />
						<input type="hidden" name="passwd" value="<%=passwd %>" />
						<li data-role="fieldcontain">
							<label for="bookdate">日期:</label>
							<% if bookdate then %>
							<input type="date" name="bookdate" id="bookdate" value="<%=bookdate %>">
							<% else %>
							<input type="date" name="bookdate" id="bookdate" >
							<% end %>
						</li>
						<% db = book.load_book(bookname) %>
						<% if book.auth_input(db,bookname,passwd) then %>
						<%
               if del then
                  _G.table.remove(db.data,_G.tonumber(del))
                  book.save_book(bookname,db)
							 end
																					%>
						<li data-role="fieldcontain">
							<label for="item">项目:</label>
							<select name="item" id="item" >
								<% for k,v in _G.pairs(db.items) do %>
								<option value="<%=k %>"> <%=k %> </option>
								<% end %>
							</select>
						</li>
						<li data-role="fieldcontain">
							<label for="person">人员:</label>
							<select name="person" id="person" >
								<% for k,v in _G.pairs(db.persons) do %>
								<option value="<%=k %>"> <%=k %> </option>
								<% end %>
							</select>
						</li>
						<li data-role="fieldcontain">
							<label for="price">消费数目:</label>
							<input type="text" name="price" id="price" >
						</li>
							<li data-role="fieldcontain">
								<label for="notes">备注:</label>
								<input type="text" name="notes" id="notes" value="none">
							</li>
							<% if bookdate and item and person and price then 
							   local t = {}
								 t.bookdate = bookdate
								 t.item = item
								 t.person = person
								 t.price = price
                 t.notes = notes
								 db.data = db.data or {}
								 _G.table.insert(db.data,t)
								 book.save_book(bookname,db)
							   end 
							%>
								<% end %>
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
									<input type="submit" value="确认" data-theme="a" >
								</li>
					</ul>
				</form>
			</div>
			<div data-role="content">
				<table width="100%" class="ui-responsive table-stripe" >
					<thead>
						<tr>
							<th >序号</th>
							<th >日期</th>
							<th >项目</th>
							<th >姓名</th>
							<th >数目</th>
							<th >备注</th>
						</tr>
					</thead>
					<tbody>
						<% if db then %>
						<% for i,v in _G.ipairs(db.data or {}) do %>
						<% if bookdate and v.bookdate == bookdate then %>
						<td><a href="book.lp?bookdate=<%=bookdate %>&bookname=<%=bookname %>&passwd=<%=passwd %>&del=<%=i %>"><%= i %></a></td>
							<td><%=v.bookdate %></td>
							<td><%=v.item %></td>
							<td><%=v.person %></td>
							<td><%=v.price %></td>
							<td><%=v.notes %></td>
						</tr>
						<% end %>
						<% end %>
						<% end %>
					</tbody>
				</table>
			</div>

			<%=book.footer %>
		</div>
	</body>
</html>	
