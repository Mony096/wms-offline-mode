part of 'business_partner_cubit.dart';

class BusinessPartnerState extends Equatable {
  const BusinessPartnerState();

  @override
  List<Object> get props => [];
}

class BusinessPartnerInitial extends BusinessPartnerState {}

class RequestingBusinessPartner extends BusinessPartnerState {}

class RequestingPaginationBusinessPartner extends BusinessPartnerState {}

class BusinessPartnerData extends BusinessPartnerState {
  final List<dynamic> entities;

  const BusinessPartnerData(this.entities);
}

class BusinessPartnerError extends BusinessPartnerState {
  final String message;

  const BusinessPartnerError(this.message);
}
