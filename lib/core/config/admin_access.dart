const adminAccountEmail = 'ngowelak@gmail.com';

bool isAdminAccountEmail(String? email) =>
    email?.trim().toLowerCase() == adminAccountEmail;
