<!DOCTYPE html> 
<% local tour = _G.require("brg.tour") %>
<% local url = _G.require("lpp.url") %>
<html> 
	<head> 
		<% if tour_no and round and desk then %>
		<title>比赛:<%=tour_no%> 轮次:<%=round %> 桌号:<%=desk %></title>
		<% else %>
		<title>桥牌计分</title> 
		<% end %>
		<%=tour.head %>
	</head> 

	<% 
	local M = {}
	M.db={}
	%>
	<% if not tour_no  then %>
	<body>
		<div data-role="page">
			<%=tour.header %>
			<div data-role="content">
				<h2>比赛列表:</h2>
				<ol data-role="listview">
					<% local tour_list = tour.load_tour_list() 
				     for k,v in _G.pairs(tour_list) do 
				local linkname = "brg.lp?tour_no=" .. url.escape(k) %>
				<li> <a href="<%=linkname %>"><%=k %></a></li>
					<% end %>
				</ol>
			</div>
			<%=tour.footer %>
		</div>
	</body>
	<% elseif not round then %>
	<body>
		<div data-role="page">
			<%=tour.header %>
			<div data-role="content">
				<h2>轮次:</h2>
				<ol data-role="listview">
					<% local tour_list = tour.load_tour_list() 
				local t = tour_list[tour_no] or {} 
				for i=1,t.rounds do
				local linkname = "brg.lp?tour_no=" .. url.escape(tour_no) .. "&round=" .. i%>
				<li> <a href="<%=linkname %>">第<%=i %>轮</a></li>
				<% end %>
				</ol>
			</div>
			<%=tour.footer %>
		</div>
	</body>
	<% elseif not desk then %>
	<body>
		<div data-role="page">
			<%=tour.header %>
			<div data-role="content">
				<h2>桌号:</h2>
				<ol data-role="listview">
					<% local tour_list = tour.load_tour_list() 
				local t = tour_list[tour_no] or {} 
				for i=1,t.desks do
				local linkname = "brg.lp?tour_no=" .. url.escape(tour_no) .. "&round=" .. round .. "&desk=" .. i%>
				<li> <a href="<%=linkname %>">第<%=i %>桌</a></li>
				<% end %>
				</ol>
			</div>
			<%=tour.footer %>
		</div>
	</body>

	<% elseif not passwd then %>
	<body>
		<div data-role="page" >
			<%=tour.header %>
			<div data-role="content">
				<form action="brg.lp" method="POST" autocomplete="off">
					<ul data-role="listview" data-insert="true">
						<li data-role="fieldcontain">
							<label for="passwd">录入密码</label>
							<input type="password" name="passwd" id="passwd">
						</li>
						<input type="hidden" name="tour_no" value="<%=tour_no %>" >
						<input type="hidden" name="round" value="<%=round %>" >
						<input type="hidden" name="desk" value="<%=desk %>" >
						<li data-role="fieldcontain">
							<input type="submit" value="确认" data-theme="b" />
						</li>
					</ul>
				</form>
			</div>
			<%=tour.footer %>
		</div>
	</body>
	<% else %>
	<%
  userlist = tour.load_user_list()
  M.db = tour.load_db(tour_no,round,desk) or {}
  M.db[tour_no] = M.db[tour_no] or {} 
  M.db[tour_no][round] = M.db[tour_no][round] or {}
  M.db[tour_no][round][desk] = M.db[tour_no][round][desk] or {}
	if N_no and S_no and E_no and W_no then																					 
	 M.db.N_no = _G.tonumber(N_no) 
	 M.db.S_no = _G.tonumber(S_no) 
	 M.db.E_no = _G.tonumber(E_no) 
	 M.db.W_no = _G.tonumber(W_no) 
	end
	local sets = {}
  local input_flag = tour.auth_input(M.db,tour_no,passwd)  

  if input_flag then
	 sets = tour.get_sets(M.db,tour_no,round,desk)
   tour.save_db(tour_no,round,desk,M.db)
  else
   sets={}																					 
  end

  local set_num,contract 
  if set and declarer and contract_num and contract_trump and contract_double and lead_color and lead_card and result_flag and result_num then
	 set_num = _G.tonumber(set)
	 contract = tour.get_contract_str(set,declarer,contract_num,contract_trump,contract_double,result_flag,result_num)
   if sets[set_num] and tour.auth_edit(tour_no,passwd) then
			sets[set_num] = nil 
			tour.save_db(tour_no,round,desk,M.db)
   elseif input_flag then
			sets[set_num] = {}
			sets[set_num].contract = contract
			sets[set_num].lead = lead_color .. lead_card
			tour.save_db(tour_no,round,desk,M.db)
   end
  end
  %>
	<body> 
		<div data-role="page">
			<%=tour.header %>
			<div data-role="content" class="ui-field-contain">	
				<% local linkname = "setuser.lp?tour_no=" .. url.escape(tour_no) .. "&round=" .. round .. "&desk=" .. desk .. "&passwd=" .. passwd %>
				<% local linknick = "设置出场名单"
			   if M.db.N_no and userlist[M.db.N_no] and M.db.S_no and userlist[M.db.S_no] and M.db.E_no and userlist[M.db.E_no] and M.db.W_no and userlist[M.db.W_no] then
			    linknick = "北:" .. userlist[M.db.N_no] .. " 南:" .. userlist[M.db.S_no] .. " 东:" .. userlist[M.db.E_no]  .. " 西:" .. userlist[M.db.W_no] 
			   end
			  %>
				<ul data-role="listview">
					<li><a href="<%=linkname %>"><%=linknick %></a></li>
				</ul>
			</div>
			<div data-role="content" class="ui-field-contain">	
				<form action="brg.lp" method="POST" autocomplete="off">
					<ul data-role="listview" data-inset="true">
						<!--
						<li data-role="fieldcontain">
							<label >比赛:<%=tour_no %> 轮次:<%=round %> 桌号:<%=desk %></label>
						</li>
						-->
						<li data-role="fieldcontain">
							<label for="set">副序:</label>
							<input type="number" name="set" id="set">
						</li>
						</li>
						<li data-role="fieldcontain">
							<fieldset data-role="controlgroup" data-type="horizontal">
								<legend>定约:</legend>
								<select name="declarer" id="declarer" data-native-menu="true">
									<option value="N">北</option>
									<option value="E">东</option>
									<option value="S">南</option>
									<option value="W">西</option>
									<option value="P">AP</option>
								</select>

								<select name="contract_num" id="contract_num" data-native-menu="true">
									<% for i=1,7 do %>
									<option value = "<%=i %>"><%=i %></option>
									<% end %>
								</select>
								<select name="contract_trump" id="contract_trump" data-native-menu="true">
									<option value="NT">NT</option>
									<option value="S">S</option>
									<option value="H">H</option>
									<option value="D">D</option>
									<option value="C">C</option>
								</select>
								<select name="contract_double" id="contract_double" data-native-menu="true">
									<option value=" ">&nbsp;</option>
									<option value="X">X</option>
									<option value="XX">XX</option>
								</select>
						</li>
						<li data-role="fieldcontain">
							<fieldset data-role="controlgroup" data-type="horizontal">
								<legend>首引</legend>
								<select name="lead_color" id="lead_color" data-native-menu="true">
									<option value="S">S</option>
									<option value="H">H</option>
									<option value="D">D</option>
									<option value="C">C</option>
								</select>
								<select name="lead_card" id="lead_card" data-native-menu="true">
									<option value="A">A</option>
									<option value="K">K</option>
									<option value="Q">Q</option>
									<option value="J">J</option>
									<option value="T">T</option>
									<option value="9">9</option>
									<option value="X">X</option>
								</select>
							</fieldset>
						</li>
						<li data-role="fieldcontain">
							<fieldset data-role="controlgroup" data-type="horizontal">
								<legend>结果</legend>
								<select name="result_flag" id="result_flag" data-native-menu="true">
									<option value="=">=</option>
									<option value="+">+</option>
									<option value="-">-</option>
								</select>
								<select name="result_num" id="result_num" data-native-menu="true">
									<% for i=0,13 do %>
									<option value="<%=i %>"><%=i %></option>
									<% end %>
								</select>
							</fieldset>
						</li>
						<!--
						<li data-role="fieldcontain">
							<div class="ui-grid-a">
								<div class="ui-block-a">
									<label for="result_flag">结果</label>
								<select name="result_flag" id="result_flag" data-native-menu="false">
									<option value="=">=</option>
									<option value="+">+</option>
									<option value="-">-</option>
								</select>
								</div>
								<div class="ui-block-b">
								<label for="result_num">墩数</label>
								<input type="number" name="result_num" id="result_num" value="0" min="0" max="13">
								</div>
							</div>
						</li>
						-->
						<input type="hidden" name="tour_no" value="<%=tour_no %>"/>
						<input type="hidden" name="round" value="<%=round %>"/>
						<input type="hidden" name="desk" value="<%=desk %>"/>
						<input type="hidden" name="passwd" value="<%=passwd %>"/>

						<% if input_flag then %>
						<li data-role="fieldcontain">
							<input type="submit" value="确认" data-theme="b" />
						</li>
						<% end %>
					</ul>
				</form>	
			</div><!-- /内容 -->

			<div data-role="content">	
				<!-- 结果列表 -->
				<table width="100%" class="ui-responsive table-stripe" >
					<thead>
						<tr>
							<th >副序</th>
							<th >定约人</th>
							<th >定约</th>
							<th >首引</th>
							<th >结果</th>
							<th >南北</th>
							<th >东西</th>
						</tr>
					</thead>
					<tbody>
		<%
							local luabridge = _G.require("brg.luabridge")
							local keys = {}
              for k,v in _G.pairs(sets) do 
                 keys[#keys+1] = k												
							end
							_G.table.sort(keys)
							for i,k in _G.ipairs(keys) do
                local v = sets[k]
								local flag,set,declarer,num,trump,double,redouble,result = luabridge.farse_contract(v.contract) 
								local con_str =""
								if not flag then con_str = "AP" end
								local ok,score = luabridge.score(v.contract)
								local ns_score,ew_score
								if score > 0 then 
									ns_score = score
								elseif score < 0 then
								  ew_score = -score
								end

	 						 if num and trump then
									 con_str = num .. trump 
							 end
							 if double then con_str = con_str .. "X" end
							 if redouble then con_str = con_str .. "XX" end 
							 if result and result == 0 then
									 result = "="
						   elseif result and result > 0 then
									 result = "+" .. result 
							 elseif result then
									 result = _G.tostring(result)
							 end
	%>
	<tr>
		<td><%=k %></td>
		<td><%=declarer %></td>
		<td><%=con_str%></td>
		<td><%=v.lead %></td>
		<td><%=result %></td>
		<td><%if ns_score then %><%=ns_score %><% end %></td>
		<td><%if ew_score then %><%=ew_score %><% end %></td>
	</tr>
	<% end %>
</tbody>
</table>
</div>

   <%=tour.footer %>
	</div>
	</body>
	<% end %>
</html>
