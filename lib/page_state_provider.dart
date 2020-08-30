import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum page_state{
  signedin_page,
  reservation_list_page,

}

class PageStateProvider with ChangeNotifier{
  page_state _page_state;

  PageStateProvider(){
    _page_state = page_state.signedin_page;
  }

  page_state getPageState()=>_page_state;
  void setPageState(page_state ps)=>_page_state = ps;
}