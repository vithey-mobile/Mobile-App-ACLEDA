package com.vithey.chat.mapper;

import com.vithey.chat.dto.response.MessageResponse;
import com.vithey.chat.dto.response.ReportResponse;
import com.vithey.chat.entity.Message;
import com.vithey.chat.entity.UserReport;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface ChatMapper {

  @Mapping(target = "messageId", source = "id")
  MessageResponse toMessageResponse(Message message);

  @Mapping(target = "reportId", source = "id")
  ReportResponse toReportResponse(UserReport report);
}
