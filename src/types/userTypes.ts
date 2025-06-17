export interface PostUserInput {
    name: string;
    email: string;
    password: string;
    username?: string;
    age?: number;
}


export interface  GetUserEmailInput {
    email: string;
}

export interface  GetUserUsernameInput {
    username: string;
}

export interface AuthenticateUserInput {
    email?: string;
    username?: string;
    password: string;
}

export interface GetUserInput {
    email?: string;
    username?: string;
}